//aggregateWithGrouping.js
import { LightningElement, wire } from "lwc";
import { gql, graphql } from "lightning/uiGraphQLApi";

export default class AggregateWithGrouping extends LightningElement {
    results;
    errors;

    @wire(graphql, {
        query: gql`
      query GroupAccountsByYear {
        uiapi {
          aggregate {
            Account(groupBy: { CreatedDate: { function: CALENDAR_YEAR } }) {
              edges {
                node {
                  aggregate {
                    Name {
                      count {
                        value
                      }
                    }
                    CreatedDate {
                      calendarYear {
                        value
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    `,
    })
    graphqlQueryResult({ data, errors }) {
        if (data) {
            this.results = data.uiapi.aggregate.Account.edges.map((edge) => edge.node);
        }
        this.errors = errors;
    }
}