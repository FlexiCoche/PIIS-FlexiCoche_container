FROM maven:3.8.6-eclipse-temurin-17 AS builder

WORKDIR /app

RUN git clone https://github.com/FlexiCoche/PIIS-FlexiCoche_back.git \
    && git clone https://github.com/FlexiCoche/PIIS-FlexiCoche_front.git

RUN mkdir -p PIIS-FlexiCoche_back/src/main/resources/static \
    && cp -r PIIS-FlexiCoche_front/* PIIS-FlexiCoche_back/src/main/resources/static/

RUN cd PIIS-FlexiCoche_back && mvn clean package -DskipTests


FROM eclipse-temurin:17-jdk-jammy
COPY --from=builder /app/PIIS-FlexiCoche_back/target/flexicoche-*.jar /app/app.jar
EXPOSE 8080
CMD ["java", "-jar", "/app/app.jar"]