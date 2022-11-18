interface HTTPCommandBuilderInput {
    uri: string;
    method: string;
    data: object;
}

export const buildCommand = ({uri, method = "GET", data = {}}: HTTPCommandBuilderInput) => {
    return `curl -d ${JSON.stringify(data)} -m ${method} ${uri}`;
}