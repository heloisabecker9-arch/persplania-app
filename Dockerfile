FROM cirrusci/flutter:stable

WORKDIR /app

COPY flutter_app/pubspec.* ./flutter_app/
RUN cd flutter_app && flutter pub get

COPY . .

RUN cd flutter_app && flutter build web --release

FROM nginx:alpine
COPY --from=0 /app/flutter_app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]