# Demo project for Flink DataStream app running over Docker

This is a sample project to run a dockerized local Flink cluster to run a simple unbounded job

### Build & Running
To just build the project
```
make mvn-build
```

To run the cluster & stop the cluster
```
make run-cluster
```
```
make stop-cluster
```

### Usage & Demo

Make script will take of setup up a new cluster using docker and execute a sample job. Make script will check current enviroment architecture and make sure to install the proper libraries & tools.

Sample job will execute a simple pipeline consuming from an infinite unbounded source and sinking into the stdout
```
  public static void main(String[] args) throws Exception {
    final StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
    env.addSource(new DataGeneratorSourceFunction(), "DataGeneratorSourceFunction")
        .print();
    env.execute();
   }
```

```
    public static class DataGeneratorSourceFunction implements SourceFunction<Long> {

    private Boolean active = true;
    private Random random = new Random();

    @Override
    public void run(SourceContext<Long> sourceContext) throws Exception {
      while (active) {
        sourceContext.collect(random.nextLong());
        Thread.sleep(1000);
      }
    }

    @Override
    public void cancel() {
      active = false;
    }
  }
```

To access the Flink UI, browse to http://localhost:8081/
