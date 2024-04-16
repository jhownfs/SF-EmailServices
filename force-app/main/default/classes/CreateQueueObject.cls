public with sharing class CreateQueueObject {
  @InvocableMethod(
    label='Create object queue'
    description='method responsible by create object queue'
    category='Queue'
  )
  public static void createQueueConfiguration(
    List<CreateQueueObjectRequest> requests
  ) {
    asyncCreateQueueObject(requests[0].queueId, requests[0].queueObject);
  }

  @future
  private static void asyncCreateQueueObject(
    String queueId,
    String queueObject
  ) {
    try {
      QueueSobject queueGroupObject = new QueueSobject();
      queueGroupObject.QueueId = queueId;
      queueGroupObject.SobjectType = queueObject;

      Database.insert(queueGroupObject);
    } catch (Exception e) {
      system.debug('e.getMessage()  ' + e.getMessage());
      system.debug('e.getCause()  ' + e.getCause());
    }
  }

  public class CreateQueueObjectRequest {
    @InvocableVariable(label='queue' description='queue name' required=true)
    public String queueId;
    @InvocableVariable(label='object' description='object name' required=true)
    public String queueObject;
  }
}
