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
* @group 
* @group-content ../../ApexDocContent/
* @description API service class for EDA HealthCheckGroup.
*/
public virtual with sharing class EDAHealthCheckGroupAPIService implements HealthCheckGroupAPIServiceInterface {

    /*********************************************
    * @description Instance for Singleton Pattern
    **********************************************/
    @TestVisible
    private static EDAHealthCheckGroupAPIService instance;

    /*********************************************************************
    * @description Empty constructor is not public for Singleton Pattern
    **********************************************************************/
    public EDAHealthCheckGroupAPIService() {}

    /******************************************************************************
    * @description Static method to get the current instance for Singleton pattern
    * @return The instance of HealthCheckGroupAPIServiceInterface.
    ******************************************************************************/
    public static HealthCheckGroupAPIServiceInterface getInstance() {

        if (instance == null) {
            instance = new EDAHealthCheckGroupAPIService();
        }

        return instance;
    }

    /**
    * getHealthCheckGroup description
    * @param  name name description
    * @return      return description
    */
    public HealthCheckGroupVModel getHealthCheckGroup(String name){
        String caseInsensitiveName = name.toLowerCase();

        List<HealthCheckItemVModel> hlthChkItemsList = new List<HealthCheckItemVModel>();
        List<String> rowKeysList = new List<String>();

        switch on caseInsensitiveName {
            when 'all success'{
                HealthCheckItemVModel hlthChkItemMod1 = 
                    new HealthCheckItemVModel('01', 
                                              'Passed Setting 1', 
                                              'Pass', 
                                              Label.stgHealthCheckStatusPassed, 
                                              'Mocked description 1', 
                                              'Mocked recommended fix 1',
                                              new List<HealthCheckItemVModel>());
                                                                                 
                HealthCheckItemVModel hlthChkItemMod2 = 
                    new HealthCheckItemVModel('02',
                                              'Passed Setting 2',
                                              'Pass',
                                              Label.stgHealthCheckStatusPassed,
                                              'Mocked description 2',
                                              'Mocked recommended fix 2',
                                              new List<HealthCheckItemVModel>());
                
                hlthChkItemsList.add(hlthChkItemMod1);
                hlthChkItemsList.add(hlthChkItemMod2);

                return new HealthCheckGroupVModel('All Success',
                                                  'Pass',
                                                  2,
                                                  2,
                                                  rowKeysList,
                                                  hlthChkItemsList);
            }

            when 'all failure' {
                rowKeysList.add('01');

                HealthCheckItemVModel hlthChkItemMod1_1 = 
                    new HealthCheckItemVModel('01.1', 
                                            'Failed Nested Setting 1', 
                                            'Fail', 
                                            Label.stgHealthCheckStatusFailed, 
                                            'Mocked nested description 1', 
                                            'Mocked nested recommended fix 1',
                                            new List<HealthCheckItemVModel>());

                HealthCheckItemVModel hlthChkItemMod1_2 = 
                    new HealthCheckItemVModel('01.2', 
                                            'Failed Nested Setting 2', 
                                            'Fail', 
                                            Label.stgHealthCheckStatusFailed, 
                                            'Mocked nested description 2', 
                                            'Mocked nested recommended fix 2',
                                            new List<HealthCheckItemVModel>());

                HealthCheckItemVModel hlthChkItemMod1 = 
                    new HealthCheckItemVModel('01', 
                                              'Failed Setting 1', 
                                              'Fail', 
                                              Label.stgHealthCheckStatusFailed, 
                                              'Mocked description 1', 
                                              'Mocked recommended fix 1',
                                              new List<HealthCheckItemVModel>{hlthChkItemMod1_1, hlthChkItemMod1_2});

                HealthCheckItemVModel hlthChkItemMod2 = 
                    new HealthCheckItemVModel('02',
                                              'Failed Setting 2',
                                              'Fail',
                                              Label.stgHealthCheckStatusFailed,
                                              'Mocked description 2',
                                              'Mocked recommended fix 2',
                                              new List<HealthCheckItemVModel>());

                hlthChkItemsList.add(hlthChkItemMod1);
                hlthChkItemsList.add(hlthChkItemMod2);

                return new HealthCheckGroupVModel('All Failure',
                                                  'Fail',
                                                  0,
                                                  3,
                                                  rowKeysList,
                                                  hlthChkItemsList);
            }

            when 'mixed' {
                rowKeysList.add('01');

                HealthCheckItemVModel hlthChkItemMod1_1 = 
                    new HealthCheckItemVModel('01.1', 
                                            'Failed Nested Setting 1', 
                                            'Fail', 
                                            Label.stgHealthCheckStatusFailed, 
                                            'Mocked nested description 1', 
                                            'Mocked nested recommended fix 1',
                                            new List<HealthCheckItemVModel>());

                HealthCheckItemVModel hlthChkItemMod1_2 = 
                    new HealthCheckItemVModel('01.2', 
                                            'Failed Nested Setting 2', 
                                            'Fail', 
                                            Label.stgHealthCheckStatusFailed, 
                                            'Mocked nested description 2', 
                                            'Mocked nested recommended fix 2',
                                            new List<HealthCheckItemVModel>());

                HealthCheckItemVModel hlthChkItemMod1 = 
                    new HealthCheckItemVModel('01', 
                                              'Failed Setting 1', 
                                              'Fail', 
                                              Label.stgHealthCheckStatusFailed, 
                                              'Mocked description 1', 
                                              'Mocked recommended fix 1',
                                              new List<HealthCheckItemVModel>{hlthChkItemMod1_1,hlthChkItemMod1_2});


                HealthCheckItemVModel hlthChkItemMod2_1 = 
                    new HealthCheckItemVModel('02.1', 
                                            'Passed Nested Setting 1', 
                                            'Pass', 
                                            Label.stgHealthCheckStatusPassed, 
                                            'Mocked nested description 1', 
                                            'Mocked nested recommended fix 1',
                                            new List<HealthCheckItemVModel>());

                HealthCheckItemVModel hlthChkItemMod2_2 = 
                    new HealthCheckItemVModel('02.2', 
                                            'Passed Nested Setting 2', 
                                            'Pass', 
                                            Label.stgHealthCheckStatusPassed, 
                                            'Mocked nested description 2', 
                                            'Mocked nested recommended fix 2',
                                            new List<HealthCheckItemVModel>());
                          
                HealthCheckItemVModel hlthChkItemMod2 = 
                    new HealthCheckItemVModel('02',
                                              'Passed Setting 2',
                                              'Pass',
                                              Label.stgHealthCheckStatusPassed,
                                              'Mocked description 2',
                                              'Mocked recommended fix 2',
                                              new List<HealthCheckItemVModel>{hlthChkItemMod2_1, hlthChkItemMod2_2});
            
                hlthChkItemsList.add(hlthChkItemMod1);
                hlthChkItemsList.add(hlthChkItemMod2);

                return new HealthCheckGroupVModel('Mixed',
                                                  'Fail',
                                                  2,
                                                  4,
                                                  rowKeysList,
                                                  hlthChkItemsList);
            }
            when else {
                return null;                
            }
        }
    }
}
