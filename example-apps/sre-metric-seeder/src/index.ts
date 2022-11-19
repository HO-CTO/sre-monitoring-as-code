import { main as mainCI } from './invoke/consoleInvoker'
import { metricTypes } from './config'
import { getCommandBuilder } from './commands/buildCommand';

const sleep = async (durationInMillis: number) => new Promise(f => setTimeout(f, durationInMillis));

(async () => {

    let count = 0;
    while (true) {
        console.log(`Running ${count++}`);
        metricTypes.forEach(({ name, serviceType, config }) => {

            let commandBuilder = getCommandBuilder(serviceType)

            // TODO: fix any on buildCommand.ts
            const commandsToInvoke: string[] = commandBuilder(config);
            
            commandsToInvoke.forEach(element => {
                mainCI(element)
            });
        });


        await sleep(500);
    }

})();
