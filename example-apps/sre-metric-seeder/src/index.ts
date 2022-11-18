import { main as mainCI } from './invoke/consoleInvoker'
import { metricTypes } from './config'
import { getCommandBuilder } from './commands/buildCommand';

const sleep = async (durationInMillis: number) => new Promise(f => setTimeout(f, durationInMillis));

(async () => {

    let count = 0;
    while(true) {
        console.log(`Running ${count++}`);
        metricTypes.forEach(({name, serviceType, config}) => {
            
            const commandBuilder = getCommandBuilder(serviceType)

            // TODO: fix below line
            // const commandsToInvoke:string[] = commandBuilder( config );
        });


        await sleep(500);
    }

})();