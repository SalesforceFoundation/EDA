trigger TDTM_Task on Task (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    hed.TDTM_Global_API.run(
        Trigger.isBefore,
        Trigger.isAfter,
        Trigger.isInsert,
        Trigger.isUpdate,
        Trigger.isDelete,
        Trigger.isUndelete,
        Trigger.new,
        Trigger.old,
        Schema.SObjectType.Task
    );
}