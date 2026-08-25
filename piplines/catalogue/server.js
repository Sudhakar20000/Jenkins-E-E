const instana = require('@instana/collector');

// Init tracing
// MUST be done before loading anything else!
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

const logger = pino({
    level: 'info',
    prettyPrint: false,
    useLevelLabels: true
});

const expLogger = expPino({
    logger: logger
});

// --------------------------------------------------
// MongoDB
// --------------------------------------------------

let db;
let collection;
let mongoConnected = false;


// --------------------------------------------------
// Express application
// --------------------------------------------------

const app = express();

app.disable('x-powered-by');

app.use(expLogger);

app.use((req, res, next) => {
    res.set('Timing-Allow-Origin', '*');
    res.set('Access-Control-Allow-Origin', '*');
    next();
});

app.use((req, res, next) => {
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

    next();
});

app.use(bodyParser.urlencoded({
    extended: true
}));

app.use(bodyParser.json());


// --------------------------------------------------
// Health Check
// --------------------------------------------------

app.get('/health', (req, res) => {
    const stat = {
        app: 'OK',
        mongo: mongoConnected
    };

    res.json(stat);
});


// --------------------------------------------------
// All Products
// --------------------------------------------------

app.get('/products', (req, res) => {

    if (mongoConnected) {

        collection
            .find({})
            .toArray()
            .then((products) => {
                res.json(products);
            })
            .catch((e) => {
                req.log.error('ERROR', e);
                res.status(500).send(e);
            });

    } else {

        req.log.error('database not available');
        res.status(500).send('database not available');

    }
});


// --------------------------------------------------
// Product By SKU
// --------------------------------------------------

app.get('/product/:sku', (req, res) => {

    if (mongoConnected) {

        const delay = process.env.GO_SLOW || 0;

        setTimeout(() => {

            collection
                .findOne({
                    sku: req.params.sku
                })
                .then((product) => {

                    req.log.info('product', product);

                    if (product) {
                        res.json(product);
                    } else {
                        res.status(404).send('SKU not found');
                    }

                })
                .catch((e) => {

                    req.log.error('ERROR', e);
                    res.status(500).send(e);

                });

        }, delay);

    } else {

        req.log.error('database not available');
        res.status(500).send('database not available');

    }
});


// --------------------------------------------------
// Products In Category
// --------------------------------------------------

app.get('/products/:cat', (req, res) => {

    if (mongoConnected) {

        collection
            .find({
                categories: req.params.cat
            })
            .sort({
                name: 1
            })
            .toArray()
            .then((products) => {

                if (products) {
                    res.json(products);
                } else {
                    res.status(404).send(
                        'No products for ' + req.params.cat
                    );
                }

            })
            .catch((e) => {

                req.log.error('ERROR', e);
                res.status(500).send(e);

            });

    } else {

        req.log.error('database not available');
        res.status(500).send('database not available');

    }
});


// --------------------------------------------------
// All Categories
// --------------------------------------------------

app.get('/categories', (req, res) => {

    if (mongoConnected) {

        collection
            .distinct('categories')
            .then((categories) => {
                res.json(categories);
            })
            .catch((e) => {

                req.log.error('ERROR', e);
                res.status(500).send(e);

            });

    } else {

        req.log.error('database not available');
        res.status(500).send('database not available');

    }
});


// --------------------------------------------------
// Search
// --------------------------------------------------

app.get('/search/:text', (req, res) => {

    if (mongoConnected) {

        collection
            .find({
                '$text': {
                    '$search': req.params.text
                }
            })
            .toArray()
            .then((hits) => {

                res.json(hits);

            })
            .catch((e) => {

                req.log.error('ERROR', e);
                res.status(500).send(e);

            });

    } else {

        req.log.error('database not available');
        res.status(500).send('database not available');

    }
});


// --------------------------------------------------
// MongoDB Connection
// --------------------------------------------------

async function mongoConnect() {

    try {

        const mongoURL =
            process.env.MONGO_URL ||
            'mongodb://mongodb:27017/catalogue';

        logger.info(`Connecting to MongoDB: ${mongoURL}`);

        const client = await MongoClient.connect(
            mongoURL,
            {
                useNewUrlParser: true,
                useUnifiedTopology: true
            }
        );

        db = client.db('catalogue');

        collection = db.collection('products');

        mongoConnected = true;

        logger.info('MongoDB connected');

    } catch (error) {

        mongoConnected = false;

        logger.error('MongoDB connection error');
        logger.error(error);

        setTimeout(mongoLoop, 2000);
    }
}


// --------------------------------------------------
// MongoDB Retry Loop
// --------------------------------------------------

function mongoLoop() {

    mongoConnect().catch((e) => {

        logger.error('MongoDB retry error');
        logger.error(e);

        setTimeout(mongoLoop, 2000);

    });
}


// --------------------------------------------------
// Start Server
// --------------------------------------------------

let server;

function startServer() {

    // Start MongoDB connection
    mongoLoop();

    const port =
        process.env.CATALOGUE_SERVER_PORT || '8081';

    server = app.listen(port, () => {

        logger.info(`Started on port ${port}`);

    });

    return server;
}


// --------------------------------------------------
// IMPORTANT
// --------------------------------------------------
//
// When Jest does:
//
//     require('../server')
//
// this condition is FALSE.
//
// Therefore:
//   - MongoDB connection does NOT start
//   - HTTP server does NOT start
//   - Port 8081 is NOT opened
//
// When you run:
//
//     node server.js
//
// this condition is TRUE.
//
// Therefore:
//   - MongoDB starts
//   - HTTP server starts
//
// --------------------------------------------------

if (require.main === module) {
    startServer();
}


// --------------------------------------------------
// Exports
// --------------------------------------------------

module.exports = app;
module.exports.startServer = startServer;