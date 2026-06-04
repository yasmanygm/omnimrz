FROM rohitkumarluthra09/react-native-android:base

ARG GRADLE_VERSION=9.3.1
ARG WRAPPER_DIST=gradle-${GRADLE_VERSION}-bin.zip

# Install Gradle 9.3.1 system-wide
RUN curl -fsSL "https://services.gradle.org/distributions/${WRAPPER_DIST}" -o /tmp/gradle.zip \
    && unzip -q /tmp/gradle.zip -d /opt/gradle \
    && rm /tmp/gradle.zip \
    && ln -sf /opt/gradle/gradle-${GRADLE_VERSION}/bin/gradle /usr/local/bin/gradle

# Install Android SDK 36, Build Tools 36, and NDK 27
RUN yes | sdkmanager \
    "platforms;android-36" \
    "build-tools;36.0.0" \
    "ndk;27.1.12297006"

# Pre-cache Gradle 9.3.1 for the Wrapper (~/.gradle/wrapper/dists/)
RUN mkdir -p /tmp/warmup \
    && cd /tmp/warmup \
    && gradle wrapper --gradle-version ${GRADLE_VERSION} --distribution-type bin \
    && ./gradlew --version \
    && cd / && rm -rf /tmp/warmup

# Nexus global config (equivalente a settings.xml)
COPY init.gradle /root/.gradle/init.gradle

ENV GRADLE_HOME=/opt/gradle/gradle-${GRADLE_VERSION}
ENV PATH=$GRADLE_HOME/bin:$PATH

WORKDIR /app
