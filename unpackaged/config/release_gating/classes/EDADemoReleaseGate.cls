/*
    Copyright (c) 2021, Salesforce.org
    All rights reserved.
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this List of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this List of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Salesforce.org nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
 * @author Salesforce.org
 * @date 2021
 * @group EDA Setup
 * @group-content
 * @description A demo release gating class to simulate EDA release gates
 */
global with sharing class EDADemoReleaseGate implements Callable {
    public static final String GET_ACTION = 'releasegate.get';
    public static final String ACTIVATE_ACTION = 'releasegate.activate';
    public static final String VERSION_PARAMETER = 'version';
    public static final String PRODUCT_PARAMETER = 'product';
    public static final String GATE_PARAMETER = 'gate';

    public class CallableError {
        public Integer code;
        public String message;

        /********************************************************************************************
         * @description Two argument constructor
         * @param  code An Integer representing the error code
         * @param  message A string representing the error message
         * @return A CallableError with all properties populated.
         ********************************************************************************************/
        public CallableError(Integer code, String message) {
            this.code = code;
            this.message = message;
        }
    }

    public virtual class CallableResult {
        public Boolean success;
        public CallableError error;

        /********************************************************************************************
         * @description Two argument constructor
         * @param  success A boolean representing if the call was successful or not
         * @param  error A CallableError representing the error in case the call was not successful
         * @return A CallableResult with all properties populated.
         ********************************************************************************************/
        public CallableResult(Boolean success, CallableError error) {
            this.success = success;
            this.error = error;
        }
    }

    public class GetReleaseGateActionResult extends CallableResult {
        public GetReleaseGateResult[] result;

        /*****************************************************************************************************************
         * @description Three argument constructor
         *****************************************************************************************************************/
        public GetReleaseGateActionResult(GetReleaseGateResult[] result, Boolean success, CallableError error) {
            super(success, error);
            this.result = result;
        }
    }

    public class GetReleaseGateResult {
        public ReleaseGateProduct product;
        public ReleaseGate[] gates;

        /*****************************************************************************************************************
         * @description Two argument constructor
         *****************************************************************************************************************/
        public GetReleaseGateResult(ReleaseGateProduct product, ReleaseGate[] gates) {
            this.product = product;
            this.gates = gates;
        }
    }

    public class ReleaseGateProduct {
        public String name;
        public String label;
        public String nextReleaseDate;

        /*****************************************************************************************************************
         * @description Three argument constructor
         *****************************************************************************************************************/
        public ReleaseGateProduct(String name, String label, String nextReleaseDate) {
            this.name = name;
            this.label = label;
            this.nextReleaseDate = nextReleaseDate;
        }
    }

    public class ReleaseGate {
        public String name;
        public String label;
        public String description;
        public Date releaseDate;
        public Date dueDate;
        public String dueDateInfoText;
        public DateTime activationDate;
        public ReleaseGateFeature[] items;
        public String status;

        /*****************************************************************************************************************
         * @description Nine argument constructor
         *****************************************************************************************************************/
        public ReleaseGate(
            String name,
            String label,
            String description,
            Date releaseDate,
            Date dueDate,
            String dueDateInfoText,
            Datetime activationDate,
            String status,
            List<ReleaseGateFeature> features
        ) {
            this.name = name;
            this.label = label;
            this.description = description;
            this.releaseDate = releaseDate;
            this.dueDate = dueDate;
            this.dueDateInfoText = dueDateInfoText;
            this.activationDate = activationDate;
            this.status = status;
            this.items = features;
        }
    }

    public class ReleaseGateFeature {
        public String name;
        public String label;
        public String description;
        public String helpLink;
        public String helpLinkLabel;

        /*****************************************************************************************************************
         * @description Five argument constructor
         *****************************************************************************************************************/
        public ReleaseGateFeature(
            String name,
            String label,
            String description,
            String helpLink,
            String helpLinkLabel
        ) {
            this.name = name;
            this.label = label;
            this.description = description;
            this.helpLink = helpLink;
            this.helpLinkLabel = helpLinkLabel;
        }
    }

    public class ActivateReleaseGateResult {
        public String productName;
        public String gateName;
        public String status;

        public ActivateReleaseGateResult(String productName, String gateName, String status) {
            this.productName = productName;
            this.gateName = gateName;
            this.status = status;
        }
    }

    public class ActivateReleaseGateActionResult extends CallableResult {
        public ActivateReleaseGateResult[] result;

        public ActivateReleaseGateActionResult(
            ActivateReleaseGateResult[] result,
            Boolean success,
            CallableError error
        ) {
            super(success, error);
            this.result = result;
        }
    }

    public EDADemoReleaseGate() {
    }

    /**
     * @description Get a list of products with release gates
     * @param  version Callable API version
     * @return         A list of products and release gates in json format
     */
    public String getReleaseGates(Decimal version) {
        List<EDADemoReleaseGate.GetReleaseGateResult> resultList = new List<EDADemoReleaseGate.GetReleaseGateResult>{
            new EDADemoReleaseGate.GetReleaseGateResult(
                new EDADemoReleaseGate.ReleaseGateProduct('SAL', 'Advisor Link', 'January 2022'),
                new List<EDADemoReleaseGate.ReleaseGate>{
                    new EDADemoReleaseGate.ReleaseGate(
                        'summer21',
                        'Summer \'21',
                        'Here\'s what\'s new in Summer \'21. See the documentation for instructions on setting up these features, and then activate the release.',
                        null,
                        Date.today().addMonths(3),
                        'On this date, we activate the current release on all sandboxes that are still on the previous release.',
                        null,
                        'inactive',
                        new List<EDADemoReleaseGate.ReleaseGateFeature>{
                            new EDADemoReleaseGate.ReleaseGateFeature(
                                'FlexibleAdviseeSnapshot',
                                'Flexible Advisee Snapshot',
                                'We\'ve redesigned the Advisee Snapshot. If desired, customize it to show up to four counters, upload advisee photos, and add the Snapshot to other Case pages.',
                                '',
                                'Set Up the Advisee Snapshot and Contact Details'
                            ),
                            new EDADemoReleaseGate.ReleaseGateFeature(
                                'FlexibleStudentSnapshot',
                                'Flexible Student Snapshot',
                                'Student Success Hub customers also enjoy the redesigned Student Snapshot. Configure the counters to show data relevant to K-12 schools, including Alerts and Success Plans, and, if desired, upload student photos and add the Snapshot to other Case pages.',
                                '',
                                'Set Up the Student Snapshot and Student Details'
                            ),
                            new EDADemoReleaseGate.ReleaseGateFeature(
                                'FrontDeskAppointmentScheduling',
                                'Front Desk Appointment Scheduling',
                                'Front desk staff can now schedule individual appointments between advisors or members of an Advising Pool and an advisee. To set up front desk scheduling, create a profile with the necessary permissions for those users, and add the Appointment Scheduler component to a Lightning page so they can access the front desk New Appointment form.',
                                '',
                                'Set Up Front Desk Appointment Scheduling'
                            )
                        }
                    ),
                    new EDADemoReleaseGate.ReleaseGate(
                        'spring21',
                        'Spring \'21',
                        'Spring \'21 is now activated for all orgs',
                        null,
                        Date.today().addMonths(6),
                        'On this date, we activate the current release on all sandboxes that are still on the previous release.',
                        Datetime.now().addMonths(-1),
                        'active',
                        new List<EDADemoReleaseGate.ReleaseGateFeature>{
                            new EDADemoReleaseGate.ReleaseGateFeature(
                                'flexscheduling',
                                'Flex Scheduling',
                                'Flexible scheduling is activated in all orgs. If you haven\'t already done so, configure location- and topic-based advising availability for your users.',
                                '',
                                'Set Up Location-Based Advising Availability'
                            ),
                            new EDADemoReleaseGate.ReleaseGateFeature(
                                'groupavailability',
                                'Group Availability',
                                'Group availability allows advisees to reserve a spot in a group advising appointment. Even if you\'re not using group availability yet, be sure you\'ve set up permissions on the Attendee Limit and Discoverable fields.',
                                '',
                                'Set Up Group Advising Availability'
                            )
                        }
                    )
                }
            ),
            new EDADemoReleaseGate.GetReleaseGateResult(
                new EDADemoReleaseGate.ReleaseGateProduct('ExampleProduct', 'Example Product', 'January 2022'),
                new List<EDADemoReleaseGate.ReleaseGate>{
                    new EDADemoReleaseGate.ReleaseGate(
                        'sampledisabled',
                        'Sample Disabled Release Gate',
                        'This is an example release gate in disabled state',
                        null,
                        Date.today().addMonths(3),
                        'On this date, we activate the current release on all sandboxes that are still on the previous release.',
                        null,
                        'disabled',
                        new List<EDADemoReleaseGate.ReleaseGateFeature>{
                            new EDADemoReleaseGate.ReleaseGateFeature(
                                'ExampleFeature1',
                                'Example disabled feature 1',
                                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
                                'https://www.salesforce.com',
                                'See example feature 1'
                            ),
                            new EDADemoReleaseGate.ReleaseGateFeature(
                                'ExampleFeature2',
                                'Example disabled feature 2',
                                'Bibendum arcu vitae elementum curabitur. Vitae ultricies leo integer malesuada nunc. Donec ac odio tempor orci dapibus ultrices. Penatibus et magnis dis parturient montes nascetur ridiculus. Dolor sit amet consectetur adipiscing elit ut aliquam. Adipiscing elit duis tristique sollicitudin nibh sit amet. Lacus laoreet non curabitur gravida arcu ac tortor. Ullamcorper a lacus vestibulum sed arcu non odio.',
                                'https://www.salesforce.com',
                                'See example feature 2'
                            )
                        }
                    ),
                    new EDADemoReleaseGate.ReleaseGate(
                        'sampleinprogress',
                        'Sample InProgress Release Gate',
                        'This is an example release gate in InProgress state',
                        null,
                        Date.today().addMonths(6),
                        'On this date, we activate the current release on all sandboxes that are still on the previous release.',
                        null,
                        'inprogress',
                        new List<EDADemoReleaseGate.ReleaseGateFeature>{
                            new EDADemoReleaseGate.ReleaseGateFeature(
                                'ExampleFeature1',
                                'Example inprogress feature 1',
                                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
                                'https://www.salesforce.com',
                                'See example feature 1'
                            ),
                            new EDADemoReleaseGate.ReleaseGateFeature(
                                'ExampleFeature2',
                                'Example inprogress feature 2',
                                'Bibendum arcu vitae elementum curabitur. Vitae ultricies leo integer malesuada nunc. Donec ac odio tempor orci dapibus ultrices. Penatibus et magnis dis parturient montes nascetur ridiculus. Dolor sit amet consectetur adipiscing elit ut aliquam. Adipiscing elit duis tristique sollicitudin nibh sit amet. Lacus laoreet non curabitur gravida arcu ac tortor. Ullamcorper a lacus vestibulum sed arcu non odio.',
                                'https://www.salesforce.com',
                                'See example feature 2'
                            )
                        }
                    ),
                    new EDADemoReleaseGate.ReleaseGate(
                        'sampleactive',
                        'Sample Active Release Gate',
                        'This is an example release gate in active state',
                        null,
                        Date.today().addMonths(6),
                        'On this date, we activate the current release on all sandboxes that are still on the previous release.',
                        Datetime.now().addMonths(-1),
                        'active',
                        new List<EDADemoReleaseGate.ReleaseGateFeature>{
                            new EDADemoReleaseGate.ReleaseGateFeature(
                                'ExampleFeature1',
                                'Example active feature 1',
                                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
                                'https://www.salesforce.com',
                                'See example feature 1'
                            ),
                            new EDADemoReleaseGate.ReleaseGateFeature(
                                'ExampleFeature2',
                                'Example active feature 2',
                                'Bibendum arcu vitae elementum curabitur. Vitae ultricies leo integer malesuada nunc. Donec ac odio tempor orci dapibus ultrices. Penatibus et magnis dis parturient montes nascetur ridiculus. Dolor sit amet consectetur adipiscing elit ut aliquam. Adipiscing elit duis tristique sollicitudin nibh sit amet. Lacus laoreet non curabitur gravida arcu ac tortor. Ullamcorper a lacus vestibulum sed arcu non odio.',
                                'https://www.salesforce.com',
                                'See example feature 2'
                            )
                        }
                    ),
                    new EDADemoReleaseGate.ReleaseGate(
                        'sampleinactive',
                        'Sample Inactive Release Gate',
                        'This is an example release gate in inactive state',
                        null,
                        Date.today().addMonths(6),
                        'On this date, we activate the current release on all sandboxes that are still on the previous release.',
                        null,
                        'inactive',
                        new List<EDADemoReleaseGate.ReleaseGateFeature>{
                            new EDADemoReleaseGate.ReleaseGateFeature(
                                'ExampleFeature1',
                                'Example inactive feature 1',
                                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
                                'https://www.salesforce.com',
                                'See example feature 1'
                            ),
                            new EDADemoReleaseGate.ReleaseGateFeature(
                                'ExampleFeature2',
                                'Example inactive feature 2',
                                'Bibendum arcu vitae elementum curabitur. Vitae ultricies leo integer malesuada nunc. Donec ac odio tempor orci dapibus ultrices. Penatibus et magnis dis parturient montes nascetur ridiculus. Dolor sit amet consectetur adipiscing elit ut aliquam. Adipiscing elit duis tristique sollicitudin nibh sit amet. Lacus laoreet non curabitur gravida arcu ac tortor. Ullamcorper a lacus vestibulum sed arcu non odio.',
                                'https://www.salesforce.com',
                                'See example feature 2'
                            )
                        }
                    )
                }
            )
        };
        //Loading states for 'summer21' and 'sampleinactive' release gates from the db
        this.loadReleaseGateStateFromDb(resultList[0].gates[0], version);
        this.loadReleaseGateStateFromDb(resultList[1].gates[3], version);

        //Removing inprogress gates to test notification tile
        if (version == 1) {
            resultList[1].gates.remove(1);
        }

        EDADemoReleaseGate.GetReleaseGateActionResult releaseGateResultModel = new EDADemoReleaseGate.GetReleaseGateActionResult(
            resultList,
            true,
            null
        );
        return JSON.serialize(releaseGateResultModel);
    }

    /**
     * @description Activate a release gate
     * @param  version     Callable API version
     * @param  productName Release gate product name
     * @param  gateName    Release gate name
     * @return             Activate release gate result in json format
     */
    public String activateReleaseGate(Decimal version, String productName, String gateName) {
        //We will create a contact to emulate gate activation
        //If a contact with the LastName=gateName exists it means the gate is active
        List<Contact> stateContacts = [SELECT Id, CreatedDate, LastName FROM Contact WHERE LastName = :gateName];
        if (stateContacts.isEmpty()) {
            Contact stateContact = new Contact();
            stateContact.LastName = gateName;
            insert stateContact;
        }
        //Emulating 'inprogress' or 'active' status for the 'sampleinactive' release gate depending on version
        String status = this.getReleaseGateState(gateName, version);
        return JSON.serialize(
            new ActivateReleaseGateActionResult(
                new List<ActivateReleaseGateResult>{ new ActivateReleaseGateResult(productName, gateName, status) },
                true,
                null
            )
        );
    }

    public Object call(String action, Map<String, Object> args) {
        System.debug('Executing callable action: ' + action);
        String result;
        if (action == GET_ACTION) {
            result = this.getReleaseGates((Decimal) args.get(VERSION_PARAMETER));
        } else if (action == ACTIVATE_ACTION) {
            result = this.activateReleaseGate(
                (Decimal) args.get(VERSION_PARAMETER),
                (String) args.get(PRODUCT_PARAMETER),
                (String) args.get(GATE_PARAMETER)
            );
        } else {
            throw new IllegalArgumentException('Method not implemented');
        }
        System.debug('Action finished, result: \r\n' + result);
        return result;
    }

    private void loadReleaseGateStateFromDb(EDADemoReleaseGate.ReleaseGate gate, Decimal version) {
        //For our mock gates we store their states in contact records
        List<Contact> stateContacts = [SELECT Id, CreatedDate, LastName FROM Contact WHERE LastName = :gate.name];
        if (!stateContacts.isEmpty()) {
            gate.status = this.getReleaseGateState(gate.name, version);
            gate.activationDate = stateContacts[0].CreatedDate;
        }
    }

    private String getReleaseGateState(String name, Decimal version) {
        // return active states for all gates if version equals to 1 to test notifications
        if (version == 1) {
            return 'active';
        } else {
            return name == 'sampleinactive' ? 'inprogress' : 'active';
        }
    }
}
