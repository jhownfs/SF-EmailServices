public with sharing class CreateQueueObject {
  @InvocableMethod(
    label='Create object queue'
    description='method responsible by create object queue'
    category='Queue'
  )
  public static void createQueueObject(
    List<CreateQueueObjectRequest> requests
  ) {
    asyncCreateQueueObject(request.queue, request.object);
  }

  @future
  private static void asyncCreateQueueObject(String queue, String object) {
    try {
      QueueSobject queueGroupObject = new QueueSobject();
      queueGroup.QueueId = queue;
      queueGroup.SobjectType = object;

      Database.insert(queueGroupObject);
    } catch (Exception e) {
      system.debug('e.getMessage()  ' + e.getMessage());
      system.debug('e.getCause()  ' + e.getCause());
    }
  }

  public class CreateQueueObjectRequest {
    @InvocableVariable(label='queue' description='queue name' required=true)
    public String queue;
    @InvocableVariable(label='object' description='object name' required=true)
    public String object;
  }
}
