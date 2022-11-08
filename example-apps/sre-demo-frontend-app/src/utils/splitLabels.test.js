const { splitLabels } = require("./splitLabels");

describe("splitLabels", () => {
  it("should split labels separated by =", () => {
    expect(splitLabels("key1=value1")).toMatchObject({
      key1: "value1",
    });
  });

  it("should return empty object if string is empty", () => {
    expect(splitLabels("")).toMatchObject({});
    expect(splitLabels("    ")).toMatchObject({});
  });

  it("should split multiple key-value pairs", () => {
    expect(splitLabels("key1=value1, key2=value2")).toMatchObject({
      key1: "value1",
      key2: "value2",
    });
  });

  it("should trim the keys and values", () => {
    expect(splitLabels("key1 = value1")).toMatchObject({
      key1: "value1",
    });
  });
});
