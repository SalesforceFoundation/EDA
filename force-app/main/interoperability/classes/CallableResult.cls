public virtual class CallableResult {
    public Boolean success;
    public CallableError error;

    public CallableResult(Boolean success, CallableError error) {
        this.success = success;
        this.error = error;
    }
}
