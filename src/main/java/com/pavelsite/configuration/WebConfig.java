package com.pavelsite.configuration;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.*;
import org.springframework.core.env.Environment;
import org.springframework.web.servlet.ViewResolver;
import org.springframework.web.servlet.config.annotation.*;
import org.springframework.web.servlet.view.InternalResourceViewResolver;

import com.pavelsite.domain.JSONService;

@Configuration
@EnableWebMvc
@ComponentScan(basePackages = "com.pavelsite")
@PropertySource("classpath:dbconnection.properties")
public class WebConfig {
	
	@Autowired
	Environment env;
	
	@Bean
	ViewResolver viewResolver() {
		InternalResourceViewResolver resolver = new InternalResourceViewResolver();
		resolver.setPrefix("/WEB-INF/");
		resolver.setSuffix(".jsp");
		return resolver;
	}
	
	@Bean
	JSONService jsonService() {
		if (!JSONService.checkDatabase()) JSONService.setDatabase(env.getProperty("db.host"), env.getProperty("db.port"), env.getProperty("db.database"), env.getProperty("db.user"), env.getProperty("db.pass"));
		return JSONService.getService();
	}
}
