const instana = require('@instana/collector');

// Instana tracing must be initialized before loading application dependencies.
instana({
    tracing: {
        enabled: true
    }
});

const { MongoClient } = require('mongodb');
const bodyParser = require('body-parser');
const express = require('express');
const pino = require('pino');
const expPino = require('express-pino-logger');

// Logger
const logger = pino({
    level: 'info',
    prettyPrint: false,
    useLevelLabels: true
});

const expLogger = expPino({
    logger: logger
});

// MongoDB
let db;
let collection;
let mongoConnected = false;
let mongoClient = null;

// Express
const app = express();

app.disable('x-powered-by');

// Logging
app.use(expLogger);

// CORS / timing headers
app.use((req, res, next) => {
    res.set('Timing-Allow-Origin', '*');
    res.set('Access-Control-Allow-Origin', '*');
    next();
});

// Instana custom span annotation
app.use((req, res, next) => {
    try {
        const dcs = [
            'asia-northeast2',
            'asia-south1',
            'europe-west3',
            'us-east1',
            'us-west1'
        ];

        const span = instana.currentSpan();

        if (span) {
            span.annotate(
                'custom.sdk.tags.datacenter',
                dcs[Math.floor(Math.random() * dcs.length)]
            );
        }
    } catch (error) {
        // Do not allow tracing errors to break the application.
        logger.warn(error, 'Unable to annotate Instana span');
    }

    next();
});

// Body parsers
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

/*
 * Health check
 */
app.get('/health', (req, res) => {
    const stat = {
        app: 'OK',
        mongo: mongoConnected
    };

    res.status(200).json(stat);
});

/*
 * Get all products
 */
app.get('/products', async (req, res) => {
    if (!mongoConnected || !collection) {
        req.log.error('database not available');
        return res.status(500).send('database not available');
    }

    try {
        const products = await collection.find({}).toArray();
        return res.status(200).json(products);
    } catch (error) {
        req.log.error(error, 'ERROR');
        return res.status(500).send(error);
    }
});

/*
 * Get product by SKU
 */
app.get('/product/:sku', (req, res) => {
    if (!mongoConnected || !collection) {
        req.log.error('database not available');
        return res.status(500).send('database not available');
    }

    // Optionally slow this down.
    const delay = Number(process.env.GO_SLOW) || 0;

    setTimeout(async () => {
        try {
            const product = await collection.findOne({
                sku: req.params.sku
            });

            req.log.info({
                sku: req.params.sku,
                product: product
            }, 'product');

            if (product) {
                return res.status(200).json(product);
            }

            return res.status(404).send('SKU not found');
        } catch (error) {
            req.log.error(error, 'ERROR');
            return res.status(500).send(error);
        }
    }, delay);
});

/*
 * Get products in a category
 */
app.get('/products/:cat', async (req, res) => {
    if (!mongoConnected || !collection) {
        req.log.error('database not available');
        return res.status(500).send('database not available');
    }

    try {
        const products = await collection
            .find({
                categories: req.params.cat
            })
            .sort({
                name: 1
            })
            .toArray();

        return res.status(200).json(products);
    } catch (error) {
        req.log.error(error, 'ERROR');
        return res.status(500).send(error);
    }
});

/*
 * Get all categories
 */
app.get('/categories', async (req, res) => {
    if (!mongoConnected || !collection) {
        req.log.error('database not available');
        return res.status(500).send('database not available');
    }

    try {
        const categories = await collection.distinct('categories');

        return res.status(200).json(categories);
    } catch (error) {
        req.log.error(error, 'ERROR');
        return res.status(500).send(error);
    }
});

/*
 * Search products by name/description
 */
app.get('/search/:text', async (req, res) => {
    if (!mongoConnected || !collection) {
        req.log.error('database not available');
        return res.status(500).send('database not available');
    }

    try {
        const hits = await collection
            .find({
                $text: {
                    $search: req.params.text
                }
            })
            .toArray();

        return res.status(200).json(hits);
    } catch (error) {
        req.log.error(error, 'ERROR');
        return res.status(500).send(error);
    }
});

/*
 * MongoDB connection
 */
async function mongoConnect() {
    try {
        const mongoURL =
            process.env.MONGO_URL ||
            'mongodb://mongodb:27017/catalogue';

        logger.info(
            {
                mongoURL: mongoURL.replace(
                    /\/\/([^:]+):([^@]+)@/,
                    '//$1:****@'
                )
            },
            'Connecting to MongoDB'
        );

        mongoClient = new MongoClient(mongoURL, {
            useNewUrlParser: true,
            useUnifiedTopology: true
        });

        await mongoClient.connect();

        db = mongoClient.db('catalogue');
        collection = db.collection('products');

        /*
         * Verify the connection.
         */
        await db.command({
            ping: 1
        });

        mongoConnected = true;

        logger.info('MongoDB connected');
    } catch (error) {
        mongoConnected = false;
        db = null;
        collection = null;

        logger.error(error, 'MongoDB connection ERROR');

        /*
         * Close partially opened client.
         */
        if (mongoClient) {
            try {
                await mongoClient.close();
            } catch (closeError) {
                logger.error(closeError, 'MongoDB close ERROR');
            }

            mongoClient = null;
        }

        /*
         * Do not immediately recurse through the promise chain.
         * mongoLoop() will retry.
         */
        setTimeout(mongoLoop, 2000);
    }
}

/*
 * MongoDB retry loop
 */
function mongoLoop() {
    if (mongoConnected) {
        return;
    }

    mongoConnect().catch((error) => {
        mongoConnected = false;

        logger.error(error, 'MongoDB retry ERROR');

        setTimeout(mongoLoop, 2000);
    });
}

/*
 * Start MongoDB connection.
 *
 * During Jest tests, allow the test suite to control/mock
 * the database state instead of forcing a real MongoDB
 * connection.
 */
if (process.env.NODE_ENV !== 'test') {
    mongoLoop();
}

/*
 * Start HTTP server only when this file is executed
 * directly by Node.
 *
 * This prevents Jest/Supertest from unnecessarily
 * creating a listening server.
 */
let server;

if (require.main === module) {
    const port = process.env.CATALOGUE_SERVER_PORT || '8081';

    server = app.listen(port, () => {
        logger.info(`Started on port ${port}`);
    });
}

/*
 * Expose app.
 *
 * Keep these properties available so tests can manipulate
 * the MongoDB state when required.
 */
app.mongo = {
    get connected() {
        return mongoConnected;
    },

    set connected(value) {
        mongoConnected = value;
    },

    get collection() {
        return collection;
    },

    set collection(value) {
        collection = value;
    },

    get db() {
        return db;
    }
};

app.mongoConnect = mongoConnect;

app.mongoLoop = mongoLoop;

app.server = server;

module.exports = app;