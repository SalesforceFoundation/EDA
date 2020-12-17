public virtual with sharing class EDAHealthCheckGroupAPIService implements HealthCheckGroupAPIServiceInterface {

    /*********************************************
    * @description Instance for Singleton Pattern
    **********************************************/
    @TestVisible
    private static EDAHealthCheckGroupAPIService instance;

    /*********************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************/
    protected EDAHealthCheckGroupAPIService() {}

    /******************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of HealthCheckGroupAPIServiceInterface.
    ******************************************************************************/
    public static HealthCheckGroupAPIServiceInterface getInstance() {

        if (instance == null) {
            instance = new EDAHealthCheckGroupAPIService();
        }

        return (HealthCheckGroupAPIServiceInterface)instance;
    }

    public HealthCheckGroupVModel getHealthCheckGroup(String name){

        List<HealthCheckItemVModel> hlthChkItemsList = new List<HealthCheckItemVModel>();
        List<String> rowKeysList = new List<String>();

        switch on name {
            when 'All Success'{
                HealthCheckItemVModel hlthChkItemMod1 = 
                    new HealthCheckItemVModel('01', 
                                              'Passed Setting 1', 
                                              'Pass', 
                                              Label.stgHealthCheckStatusPassed, 
                                              'Mocked description 1', 
                                              'Mocked recommended fix 1');
                                                                                 
                HealthCheckItemVModel hlthChkItemMod2 = 
                    new HealthCheckItemVModel('02',
                                              'Passed Setting 2',
                                              'Pass',
                                              Label.stgHealthCheckStatusPassed,
                                              'Mocked description 2',
                                              'Mocked recommended fix 2');
                
                hlthChkItemsList.add(hlthChkItemMod1);
                hlthChkItemsList.add(hlthChkItemMod2);




                return new HealthCheckGroupVModel('All Success',
                                                  'Pass',
                                                  2,
                                                  2,
                                                  rowKeysList,
                                                  hlthChkItemsList);
            }










            when 'All Failure' {
                rowKeysList.add('01');

                HealthCheckItemVModel hlthChkItemMod1 = 
                    new HealthCheckItemVModel('01', 
                                              'Failed Setting 1', 
                                              'Fail', 
                                              Label.stgHealthCheckStatusFailed, 
                                              'Mocked description 1', 
                                              'Mocked recommended fix 1');


                HealthCheckItemVModel hlthChkItemMod1_1 = 
                    new HealthCheckItemVModel('01.1', 
                                            'Failed Nested Setting 1', 
                                            'Fail', 
                                            Label.stgHealthCheckStatusFailed, 
                                            'Mocked nested description 1', 
                                            'Mocked nested recommended fix 1');

                HealthCheckItemVModel hlthChkItemMod1_2 = 
                    new HealthCheckItemVModel('01.2', 
                                            'Failed Nested Setting 2', 
                                            'Fail', 
                                            Label.stgHealthCheckStatusFailed, 
                                            'Mocked nested description 2', 
                                            'Mocked nested recommended fix 2');
                                                                                 
                HealthCheckItemVModel hlthChkItemMod2 = 
                    new HealthCheckItemVModel('02',
                                              'Failed Setting 2',
                                              'Fail',
                                              Label.stgHealthCheckStatusFailed,
                                              'Mocked description 2',
                                              'Mocked recommended fix 2');

                hlthChkItemsList.add(hlthChkItemMod1);
                hlthChkItemsList.add(hlthChkItemMod1_1);
                hlthChkItemsList.add(hlthChkItemMod1_2);
                hlthChkItemsList.add(hlthChkItemMod2);

                return new HealthCheckGroupVModel('All Failure',
                                                  'Fail',
                                                  0,
                                                  3,
                                                  rowKeysList,
                                                  hlthChkItemsList);
            }



            when else {
                // 'Mixed'
                rowKeysList.add('01');

                HealthCheckItemVModel hlthChkItemMod1 = 
                    new HealthCheckItemVModel('01', 
                                              'Failed Setting 1', 
                                              'Fail', 
                                              Label.stgHealthCheckStatusFailed, 
                                              'Mocked description 1', 
                                              'Mocked recommended fix 1');


                HealthCheckItemVModel hlthChkItemMod1_1 = 
                    new HealthCheckItemVModel('01.1', 
                                            'Failed Nested Setting 1', 
                                            'Fail', 
                                            Label.stgHealthCheckStatusFailed, 
                                            'Mocked nested description 1', 
                                            'Mocked nested recommended fix 1');

                HealthCheckItemVModel hlthChkItemMod1_2 = 
                    new HealthCheckItemVModel('01.2', 
                                            'Failed Nested Setting 2', 
                                            'Fail', 
                                            Label.stgHealthCheckStatusFailed, 
                                            'Mocked nested description 2', 
                                            'Mocked nested recommended fix 2');
                                                                                 
                HealthCheckItemVModel hlthChkItemMod2 = 
                    new HealthCheckItemVModel('02',
                                              'Passed Setting 2',
                                              'Pass',
                                              Label.stgHealthCheckStatusPassed,
                                              'Mocked description 2',
                                              'Mocked recommended fix 2');

                HealthCheckItemVModel hlthChkItemMod2_1 = 
                    new HealthCheckItemVModel('02.1', 
                                            'Passed Nested Setting 1', 
                                            'Pass', 
                                            Label.stgHealthCheckStatusPassed, 
                                            'Mocked nested description 1', 
                                            'Mocked nested recommended fix 1');

                HealthCheckItemVModel hlthChkItemMod2_2 = 
                    new HealthCheckItemVModel('02.2', 
                                            'Passed Nested Setting 2', 
                                            'Pass', 
                                            Label.stgHealthCheckStatusPassed, 
                                            'Mocked nested description 2', 
                                            'Mocked nested recommended fix 2');

                hlthChkItemsList.add(hlthChkItemMod1);
                hlthChkItemsList.add(hlthChkItemMod1_1);
                hlthChkItemsList.add(hlthChkItemMod1_2);
                hlthChkItemsList.add(hlthChkItemMod2);
                hlthChkItemsList.add(hlthChkItemMod2_1);
                hlthChkItemsList.add(hlthChkItemMod2_2);

                return new HealthCheckGroupVModel('Mixed',
                                                  'Fail',
                                                  2,
                                                  4,
                                                  rowKeysList,
                                                  hlthChkItemsList);
            }
        }
    }
    
}
