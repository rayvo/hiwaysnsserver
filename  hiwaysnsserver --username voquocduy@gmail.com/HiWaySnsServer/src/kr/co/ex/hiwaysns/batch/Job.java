package kr.co.ex.hiwaysns.batch;

import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

public interface Job extends org.quartz.Job{
	public void execute(JobExecutionContext context)
    throws JobExecutionException;
}
