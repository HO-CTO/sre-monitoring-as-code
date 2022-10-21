import axios from "axios";

export const client = axios.create({
  baseURL: "http://localhost:4001",
  headers: {
    "Access-Control-Allow-Origin": "*",
    "Content-Type": "application/json",
  },
});
