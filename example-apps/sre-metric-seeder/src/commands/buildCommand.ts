import { buildCommand as awsBC } from "./aws";
import { buildCommand as httpBC } from "./http";


export const getCommandBuilder = (serviceType: ServiceType) => {
    switch (serviceType) {
        case ServiceType.AWS:
            return awsBC;
        case ServiceType.HTTP:
            return httpBC;
    }
}