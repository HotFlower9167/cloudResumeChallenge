const { app } = require('@azure/functions');
const { CosmosClient } = require('@azure/cosmos');

const endpoint = process.env.COSMOS_DB_ENDPOINT;
const key = process.env.COSMOS_DB_KEY;
const databaseId = process.env.COSMOS_DB_NAME;
const containerId = process.env.COSMOS_DB_CONTAINER;

const client = new CosmosClient({ endpoint, key });

app.http('sendResume', {
    methods: ['post'],
    authLevel: 'function',
    handler: async (request, context) => {
        context.log('Sending resume to the system');

        const resume = await request.json();
        context.log("Here the resume: "+resume.basics.name)

        if (resume) {
            const container = client.database(databaseId).container(containerId);
            const createdItemResponse = await container.items.create(resume);
            const createdItem = createdItemResponse.resource;

            return { body: `Resume sent successfully. ID: ${createdItem.id} \nThank you ${resume.basics.name}` };
        } else {
            return { body: 'Send a valid resume as JSON' };
        }
    }
});