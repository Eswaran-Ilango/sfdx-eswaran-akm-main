// datatableWithGraphqlPagination.js
import { LightningElement, wire } from "lwc";
import { gql, graphql } from "lightning/uiGraphQLApi";

const columns = [
    { label: "Name", fieldName: "Name" },
    { label: "Phone", fieldName: "Phone", type: "phone" },
    { label: "Website", fieldName: "Website", type: "url" },
    { label: "Annual Revenue", fieldName: "AnnualRevenue", type: "currency" },
];

export default class DatatableWithGraphqlPagination extends LightningElement {
    // Array of accounts to display
    accounts = undefined;
    // Erors from the wire adapter
    errors = undefined;
    // Columns for datatable
    columns = columns;

    // Cursor of the last returned record
    lastCursor = null;

    // Cursor for the next page
    endCursor = null;

    // Checks if the page is the last page
    // Disables the next page button if true
    isFinalPage = false;

    // Total number of query results
    totalCount = null;
    page = 1;
    totalPages = 1;
    isFirstPage;
    cursorStack = [];
    
    @wire(graphql, {
        query: "$accountQuery",
        variables: "$variables",
    })
    gqlQuery({ data, errors }) {
        if (data) {
            console.log('gqlQuery: - "DatatableWithGraphqlPagination"', JSON.stringify(data, null, 4));
            this.accounts = data.uiapi.query.Account.edges.map((edge) => ({
                Id: edge.node.Id,
                Name: edge.node.Name.value,
                Phone: edge.node.Phone.value,
                Website: edge.node.Website.value,
                AnnualRevenue: edge.node.AnnualRevenue.value,
            }));
            this.isFinalPage = !data.uiapi.query.Account.pageInfo.hasNextPage;
            this.endCursor = data.uiapi.query.Account.pageInfo.endCursor;
            this.totalCount = data.uiapi.query.Account.totalCount;
            this.totalPages = Math.ceil(this.totalCount / 5);
            this.isFirstPage = !data.uiapi.query.Account.pageInfo.hasPreviousPage;
        }
        this.errors = errors;
    }

    // Define the GraphQL query
    get accountQuery() {
        return gql`
      query AccountWithName($after: String) {
        uiapi {
          query {
            Account(first: 5, after: $after) {
              edges {
                node {
                  Id
                  Name {
                    value
                  }
                  Phone {
                    value
                  }
                  Website {
                    value
                  }
                  AnnualRevenue {
                    value
                  }
                }
              }
              pageInfo {
                endCursor
                hasNextPage
                hasPreviousPage
              }
              totalCount
            }
          }
        }
      }
    `;
    }

    // Define variables for the GraphQL query
    get variables() {
        return {
            after: this.lastCursor,
        };
    }

    get currentPage() {
        return this.totalCount === 0 ? 0 : this.page;
    }

    // Click handler for the reset button
    resetPagingCursor(event) {
        this.lastCursor = null;
        this.page = 1;
        this.cursorStack = [];
    }

    // Click handler for the next page button
    getNextPage(event) {
        if (!this.isFinalPage) {
            this.cursorStack.push(this.lastCursor);
            this.lastCursor = this.endCursor;
            this.page++;
        }
    }

    getPreviousPage() {
        if (!this.isFirstPage && this.cursorStack.length > 0) {
            this.lastCursor = this.cursorStack.pop();
            this.page--;
        }
    }
}