package com.matiasnicoletti.flinkdatastreamdemo;

import java.time.Instant;
import java.util.Random;
import lombok.extern.slf4j.Slf4j;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.source.SourceFunction;

@Slf4j
public class UnboundedSourceSampleJob {

  public static void main(String[] args) throws Exception {
    final StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

    env.addSource(new DataGeneratorSourceFunction(), "DataGeneratorSourceFunction")
        .print();

    log.info("Job start time at {}", Instant.now());
    env.execute();
  }

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
}
