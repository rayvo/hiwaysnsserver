package kr.co.ex.hiwaysns.batch;

import static org.quartz.DateBuilder.evenMinuteDate;
import static org.quartz.JobBuilder.newJob;
import static org.quartz.SimpleScheduleBuilder.simpleSchedule;
import static org.quartz.TriggerBuilder.newTrigger;

import java.io.IOException;
import java.util.Date;

import javax.servlet.GenericServlet;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;

import org.quartz.JobDetail;
import org.quartz.Scheduler;
import org.quartz.SchedulerFactory;
import org.quartz.Trigger;
import org.quartz.impl.StdSchedulerFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SchedulerServlet extends GenericServlet {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	/**
	 * Constant to represent property for the cron expression.
	 */

	public void init(ServletConfig servletConfig) throws ServletException {
		Logger log = LoggerFactory.getLogger(SchedulerServlet.class);
		super.init(servletConfig);

		// The Quartz Scheduler
		Scheduler scheduler = null;

		try {

			// Initiate a Schedule Factory
			SchedulerFactory schedulerFactory = new StdSchedulerFactory();
			// Retrieve a scheduler from schedule factory
			scheduler = schedulerFactory.getScheduler();
			// Initiate JobDetail with job name, job group and
			// executable job class
			// define the job and tie it to our EncryptJob class
	        JobDetail job = newJob(EncryptJob.class)
	            .withIdentity("CCTV_URL_Encryption", "Job")
	            .build();
	        
			// Initiate CronTrigger with its name and group name
			//CronTrigger cronTrigger = new CronTrigger("cronTrigger", "triggerGroup");
	     // computer a time that is on the next round minute
	        Date runTime = evenMinuteDate(new Date());
	        //Date runTime = new Date();
	        log.info(job.getKey() + " will run at: " + runTime);
	        
			 // Trigger the job to run on the next round minute
	        Trigger trigger = newTrigger()
		        .withIdentity("trigger3", "group1")
		        .startAt(runTime)
		        .withSchedule(simpleSchedule()
		                .withIntervalInHours(24)
		        		//.repeatForever())
		        		//.withIntervalInMinutes(10)
		                //.withIntervalInMilliseconds(25000)
		                .repeatForever())
		        .build();
	        
			// setup CronExpression
			//CronExpression cexp = new CronExpression(CRON_EXPRESSION);
			// Assign the CronExpression to CronTrigger
			//cronTrigger.setCronExpression(cexp);
			// schedule a job with JobDetail and Trigger
			//RayVo TODO scheduler.scheduleJob(job, trigger);

			// start the scheduler
	      //RayVo TODO scheduler.start();

		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	public void service(ServletRequest serveletRequest,
			ServletResponse servletResponse) throws ServletException,
			IOException {

	}
}
