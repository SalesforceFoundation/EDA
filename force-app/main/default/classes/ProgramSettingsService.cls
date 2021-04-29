public virtual with sharing class ProgramSettingsService {
    /*********************************************
     * @description Instance for Singleton Pattern
     **********************************************/
    @TestVisible
    private static ProgramSettingsService instance;

    /*********************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************/
    protected ProgramSettingsService() {
    }

    /*****************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of ProgramSettingsService.
     ******************************************************************************/
    public static ProgramSettingsService getInstance() {
        if (instance == null) {
            instance = new ProgramSettingsService();
        }

        return instance;
    }

    /****************************************************************************
     * @description Retrieve model representing program settings specified in
     * hierarchy settings.
     * @return A ProgramSettingsModel
     ****************************************************************************/
    public ProgramSettingsModel getProgramSettingsModel() {
        return this.locateProgramSettingsMapper().getProgramSettingsModel();
    }

    /****************************************************************************
     * @description Retrieve an instance of ProgramSettingsMapper
     * @return An instance of the ProgramSettingsMapper class
     ****************************************************************************/
    @TestVisible
    private ProgramSettingsMapper locateProgramSettingsMapper() {
        return ProgramSettingsMapper.getInstance();
    }
}
