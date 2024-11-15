/*
   Copyright (C) 2023  Argyros Argyridis arargyridis at gmail dot com
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

#ifndef SMTPSERVER_H
#define SMTPSERVER_H

#include <curl/curl.h>
#include <memory>
#include <string>


class SmtpServer {
    struct upload_status {
        size_t bytes_read;
        std::string message;
    };
    using CURLUniquePtr = std::unique_ptr<CURL, void(*)(CURL*)>;
    upload_status uploadCtx;

    CURLUniquePtr curl;
    curl_slist *recipients;
    CURLcode res;

public:
    SmtpServer(std::string& smtp, std::string& userName, std::string& password, std::string& certPath, bool selfSigned =true);
    ~SmtpServer();
    void setData(std::string& from, std::string& to, std::string& subject, std::string& body, std::string cc="");
    CURLcode send(bool verbose = false);

    static size_t payloadSource(char* ptr, size_t size, size_t nmemb, void* userp);
};


#endif //SMTPSERVER_H

