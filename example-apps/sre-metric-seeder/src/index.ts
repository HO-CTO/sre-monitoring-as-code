import main from './invoke/invoker'

const sleep = async (durationInMillis: number) => new Promise(f => setTimeout(f, durationInMillis));

(async () => {

    let count = 0;
    while(true) {
        console.log(`Running ${count++}`);
        await sleep(500);
    }

})();