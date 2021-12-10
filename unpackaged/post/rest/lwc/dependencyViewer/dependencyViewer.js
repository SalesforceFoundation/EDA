import { LightningElement } from 'lwc';

// import getDependencyStructure from "@salesforce/apex/DependencyApi.doGet";

export default class DependencyViewer extends LightningElement {

    connectedCallback(){
        // getDependencyStructure()
        // .then(result => {
        //     console.log(result);
        //     this.dependencyJson = result;
        // })
        // .catch(error => {
        //     console.log('Error: '+error.body.message);
        // });
    }

    dependencyJson = [
        {
            "name":"Entity: Opportunity",
            "label":"Entity: Opportunity",
            "items":[
               {
                  "name":"Field: Opportunity.Id",
                  "label":"Field: Opportunity.Id",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.IsDeleted",
                  "label":"Field: Opportunity.IsDeleted",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.AccountId",
                  "label":"Field: Opportunity.AccountId",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.IsPrivate",
                  "label":"Field: Opportunity.IsPrivate",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.Name",
                  "label":"Field: Opportunity.Name",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.Description",
                  "label":"Field: Opportunity.Description",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.StageName",
                  "label":"Field: Opportunity.StageName",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.Amount",
                  "label":"Field: Opportunity.Amount",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.Probability",
                  "label":"Field: Opportunity.Probability",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.ExpectedRevenue",
                  "label":"Field: Opportunity.ExpectedRevenue",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.TotalOpportunityQuantity",
                  "label":"Field: Opportunity.TotalOpportunityQuantity",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.CloseDate",
                  "label":"Field: Opportunity.CloseDate",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.Type",
                  "label":"Field: Opportunity.Type",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.NextStep",
                  "label":"Field: Opportunity.NextStep",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.LeadSource",
                  "label":"Field: Opportunity.LeadSource",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.IsClosed",
                  "label":"Field: Opportunity.IsClosed",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.IsWon",
                  "label":"Field: Opportunity.IsWon",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.ForecastCategory",
                  "label":"Field: Opportunity.ForecastCategory",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.ForecastCategoryName",
                  "label":"Field: Opportunity.ForecastCategoryName",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.CampaignId",
                  "label":"Field: Opportunity.CampaignId",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.HasOpportunityLineItem",
                  "label":"Field: Opportunity.HasOpportunityLineItem",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.Pricebook2Id",
                  "label":"Field: Opportunity.Pricebook2Id",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.OwnerId",
                  "label":"Field: Opportunity.OwnerId",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.CreatedDate",
                  "label":"Field: Opportunity.CreatedDate",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.CreatedById",
                  "label":"Field: Opportunity.CreatedById",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.LastModifiedDate",
                  "label":"Field: Opportunity.LastModifiedDate",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.LastModifiedById",
                  "label":"Field: Opportunity.LastModifiedById",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.SystemModstamp",
                  "label":"Field: Opportunity.SystemModstamp",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.LastActivityDate",
                  "label":"Field: Opportunity.LastActivityDate",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.PushCount",
                  "label":"Field: Opportunity.PushCount",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.LastStageChangeDate",
                  "label":"Field: Opportunity.LastStageChangeDate",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.Fiscal",
                  "label":"Field: Opportunity.Fiscal",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.ContactId",
                  "label":"Field: Opportunity.ContactId",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.LastViewedDate",
                  "label":"Field: Opportunity.LastViewedDate",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.LastReferencedDate",
                  "label":"Field: Opportunity.LastReferencedDate",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.UserRecordAccessId",
                  "label":"Field: Opportunity.UserRecordAccessId",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.RecordVisibilityId",
                  "label":"Field: Opportunity.RecordVisibilityId",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.PartnerAccountId",
                  "label":"Field: Opportunity.PartnerAccountId",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.ContractId",
                  "label":"Field: Opportunity.ContractId",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.HasOpenActivity",
                  "label":"Field: Opportunity.HasOpenActivity",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.HasOverdueTask",
                  "label":"Field: Opportunity.HasOverdueTask",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.IqScore",
                  "label":"Field: Opportunity.IqScore",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.LastAmountChangedHistoryId",
                  "label":"Field: Opportunity.LastAmountChangedHistoryId",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.LastCloseDateChangedHistoryId",
                  "label":"Field: Opportunity.LastCloseDateChangedHistoryId",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.Completed_FAFSA__c",
                  "label":"Field: Opportunity.Completed_FAFSA__c",
                  "items":[
                     {
                        "name":"Layout: EDA Opportunity Layout",
                        "label":"Layout: EDA Opportunity Layout",
                        "items":[
                           
                        ],
                        "expanded":false
                     },
                     {
                        "name":"CustomField: Neil_Test",
                        "label":"CustomField: Neil_Test",
                        "items":[
                           {
                              "name":"Layout: EDA Opportunity Layout",
                              "label":"Layout: EDA Opportunity Layout",
                              "items":[
                                 
                              ],
                              "expanded":false
                           }
                        ],
                        "expanded":false
                     }
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.Desired_Campus__c",
                  "label":"Field: Opportunity.Desired_Campus__c",
                  "items":[
                     
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.Desired_Degree_Level__c",
                  "label":"Field: Opportunity.Desired_Degree_Level__c",
                  "items":[
                     {
                        "name":"Layout: EDA Opportunity Layout",
                        "label":"Layout: EDA Opportunity Layout",
                        "items":[
                           
                        ],
                        "expanded":false
                     }
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.Desired_Start_Term__c",
                  "label":"Field: Opportunity.Desired_Start_Term__c",
                  "items":[
                     {
                        "name":"Layout: EDA Opportunity Layout",
                        "label":"Layout: EDA Opportunity Layout",
                        "items":[
                           
                        ],
                        "expanded":false
                     }
                  ],
                  "expanded":false
               },
               {
                  "name":"Field: Opportunity.Living_Situation__c",
                  "label":"Field: Opportunity.Living_Situation__c",
                  "items":[
                     
                  ],
                  "expanded":false
               }
            ],
            "expanded":true
         }
    ];

}