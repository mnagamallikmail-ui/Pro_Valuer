package com.bwvr.backend.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI bwvrOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("BwVr Report Management System API")
                        .description("REST API for managing bank report templates and generated reports. "
                                + "Every report has a unique auto-generated reference number.")
                        .version("1.0.0")
                        .contact(new Contact()
                                .name("BwVr Team")
                                .email("support@bwvr.com"))
                        .license(new License().name("Proprietary")))
                .servers(List.of(
                        new Server().url("/").description("Default Server")
                ));
    }
}
