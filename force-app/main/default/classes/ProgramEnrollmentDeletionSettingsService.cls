public virtual with sharing class ProgramEnrollmentDeletionSettingsService {
    /*********************************************
     * @description Instance for Singleton Pattern
     **********************************************/
    @TestVisible
    private static ProgramEnrollmentDeletionSettingsService instance;

    /*********************************************************************
     * @description Empty constructor is not public for Singleton Pattern
     **********************************************************************/
    protected ProgramEnrollmentDeletionSettingsService() {
    }

    /*****************************************************************************
     * @description Static method to get the current instance for Singleton pattern
     * @return The instance of ProgramEnrollmentDeletionSettingsService.
     ******************************************************************************/
    public static ProgramEnrollmentDeletionSettingsService getInstance() {
        if (instance == null) {
            instance = new ProgramEnrollmentDeletionSettingsService();
        }

        return instance;
    }

    /****************************************************************************
     * @description Retrieve model representing program settings specified in
     * hierarchy settings.
     * @return A ProgramEnrollmentDeletionSettingsModel
     ****************************************************************************/
    public ProgramEnrollmentDeletionSettingsModel getProgramEnrollmentDeletionSettingsModel() {
        return this.locateProgramEnrollmentDeletionSettingsMapper().getProgramEnrollmentDeletionSettingsModel();
    }

    /****************************************************************************
     * @description Retrieve an instance of ProgramEnrollmentDeletionSettingsMapper
     * @return An instance of the ProgramEnrollmentDeletionSettingsMapper class
     ****************************************************************************/
    @TestVisible
    private ProgramEnrollmentDeletionSettingsMapper locateProgramEnrollmentDeletionSettingsMapper() {
        return ProgramEnrollmentDeletionSettingsMapper.getInstance();
    }
}
