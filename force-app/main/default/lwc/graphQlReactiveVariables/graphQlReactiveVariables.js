import { LightningElement, wire } from "lwc";
import { gql, graphql } from 'lightning/uiGraphQLApi';
export default class GraphQlReactiveVariables extends LightningElement {
    records;
    errors;

    minAmount = "5000000";

    minAmounts = [
        { label: "All", value: "0" },
        { label: "$5,000,000", value: "5000000" },
        { label: "$50,000,000", value: "50000000" },
        { label: "$500,000,000", value: "500000000" },
    ];

    @wire(graphql, {
        query: '$getQuery',
        variables: "$variables", // Use a getter function to make the variables reactive
    })
    graphqlQueryResult({ data, errors }) {
        if (data) {
            this.records = data.uiapi.query.Account.edges.map((edge) => edge.node);
            console.log('graphqlQueryResult: - "GraphQlReactiveVariables"', JSON.stringify(data, null, 4));
        }
        this.errors = errors;
    }

    get variables() {
        return {
            minAmount: this.minAmount,
        };
    }

    get getQuery() {
        return gql`
        query bigAccounts($minAmount: Currency) {
            uiapi {
                query {
                    Account(where: { AnnualRevenue: { gte: $minAmount } }) {
                        edges {
                            node {
                                Id
                                Name {
                                    value
                                }
                                AnnualRevenue {
                                    displayValue
                                }
                            }
                        }
                    }
                }
            }
        }`;
    }

    // Called when the user selects a new minimum amount
    handleMinAmountChange(event) {
        this.minAmount = event.detail.value;
    }
}