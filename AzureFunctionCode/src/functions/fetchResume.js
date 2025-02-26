const app = require('@azure/functions').app;
const cosmosClient = require('@azure/cosmos').CosmosClient;

// fetch from env variables the Cosmos DB connection details
const endpoint = process.env.COSMOS_DB_ENDPOINT;
const key = process.env.COSMOS_DB_KEY;
const databaseId = process.env.COSMOS_DB_NAME;
const containerId = process.env.COSMOS_DB_CONTAINER;

// create a Cosmos DB client
const dbClient = new cosmosClient({ endpoint, key });

app.http('fetchResume', {
    methods: ['get'],
    authLevel: 'function',
    handler: async (request, context) => {

        const resumeID = await request.query.get('resumeID');
        context.log(resumeID)

        if (resumeID) {
            context.log('Fetching the resume requested');
            const container = dbClient.database(databaseId).container(containerId);
            const fetchResumeResponse = await container.item(resumeID).read();
            //const testfetch = await container.item(resumeID).ItemResponse;
            context.log(fetchResumeResponse.item.clientContext.clientConfig.sDKVersion)
            if (fetchResumeResponse.statusCode === 404) {
                context.log('Resume not found');
                return { body: `Resume with ID ${resumeID} not found` }
            } else {
                return {
                    jsonBody:fetchResumeResponse.resource
                }
            }
        }
        else {
            return {
                body: "Please provide a resume ID to fetch"

            }
        }
    }
})