const { promClient, register } = require("./index");

describe("register", () => {

    it("should remove a single metric", async () => {
        const counter = new promClient.Counter({name: "test1", help: "test1"});
        register.registerMetric(counter);
       expect(register.getSingleMetric(counter.name)).not.toBeUndefined();


       register.removeSingleMetric("test1");
       expect(register.getSingleMetric(counter.name)).toBeUndefined();
       counter.remove()

       const counter1 = new promClient.Counter({name: "test1", help: "test1"});
       register.registerMetric(counter1);

       expect(register.getSingleMetric(counter1.name)).not.toBeUndefined();

    });


})