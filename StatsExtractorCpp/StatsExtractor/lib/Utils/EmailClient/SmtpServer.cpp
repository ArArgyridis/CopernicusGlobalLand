/*
   Copyright (C) 2024  Argyros Argyridis arargyridis at gmail dot com
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <iostream>
#include <stdio.h>
#include <string.h>
#include <sstream>

#include "SmtpServer.h"

size_t SmtpServer::payloadSource(char *ptr, size_t size, size_t nmemb, void *userp) {
    SmtpServer::upload_status *upload_ctx = static_cast<SmtpServer::upload_status*>(userp);

    size_t room = size * nmemb;

    if((size == 0) || (nmemb == 0) || ((room) < 1))
        return 0;


    size_t len = strlen(&upload_ctx->message[upload_ctx->bytes_read]);
    if (upload_ctx->message.size() > upload_ctx->bytes_read) {
        if(room < len)
            len = room;
        memcpy(ptr, &upload_ctx->message[upload_ctx->bytes_read], len);
        upload_ctx->bytes_read += len;
        return len;
    }
    return 0;
}

SmtpServer::SmtpServer(std::string &smtp, std::string &userName, std::string &password, std::string &certPath, bool selfSigned): curl(CURLUniquePtr(curl_easy_init(), &curl_easy_cleanup)),
    uploadCtx({ 0, ""}),recipients(nullptr) {

    curl_easy_setopt(curl.get(), CURLOPT_URL, smtp.c_str());
    curl_easy_setopt(curl.get(), CURLOPT_USERNAME, userName.c_str());
    curl_easy_setopt(curl.get(), CURLOPT_PASSWORD, password.c_str());
    curl_easy_setopt(curl.get(), CURLOPT_USE_SSL, (long)CURLUSESSL_ALL);
    curl_easy_setopt(curl.get(), CURLOPT_CAINFO, certPath.c_str());
    curl_easy_setopt(curl.get(), CURLOPT_SSL_VERIFYPEER, 0L);
    curl_easy_setopt(curl.get(), CURLOPT_SSL_VERIFYHOST, 0L);
    curl_easy_setopt(curl.get(), CURLOPT_UPLOAD, 1L);
    curl_easy_setopt(curl.get(), CURLOPT_VERBOSE, 1L);

    if(selfSigned) {
        curl_easy_setopt(curl.get(), CURLOPT_SSL_VERIFYPEER, 0L);
        curl_easy_setopt(curl.get(), CURLOPT_SSL_VERIFYHOST, 0L);
    }

}

SmtpServer::~SmtpServer(){
    curl_slist_free_all(recipients);
}

void SmtpServer::setData(std::string &from, std::string &to, std::string &subject, std::string &body, std::string cc) {
    curl_easy_setopt(curl.get(), CURLOPT_MAIL_FROM, from.c_str());
    recipients = curl_slist_append(recipients, to.c_str());


    std::stringstream email;
    email << "To: " << to << "\r\n" <<
        "From: "<< from << "\r\n";

    if (cc.size() > 0) {
        recipients = curl_slist_append(recipients, cc.c_str());
        email << "Cc: " << cc << "\r\n";
    }


    email << "Subject: " << subject << "\r\n" <<
        "\r\n" /* empty line to divide headers from body, see RFC 5322 */<<
        body << "\r\n";

    uploadCtx.message = email.str();
    curl_easy_setopt(curl.get(), CURLOPT_MAIL_RCPT, recipients);
    curl_easy_setopt(curl.get(), CURLOPT_READFUNCTION, SmtpServer::payloadSource);
    curl_easy_setopt(curl.get(), CURLOPT_READDATA, &uploadCtx);
    curl_easy_setopt(curl.get(), CURLOPT_UPLOAD, 1L);
    curl_easy_setopt(curl.get(), CURLOPT_VERBOSE, 1L);

}

CURLcode SmtpServer::send(bool verbose) {
    if (verbose)
        curl_easy_setopt(curl.get(), CURLOPT_VERBOSE, 1L);

    res = curl_easy_perform(curl.get());
    if(res != CURLE_OK)
        std::cerr << "curl_easy_perform() failed: " << curl_easy_strerror(res) << "\n";

    return res;

}
