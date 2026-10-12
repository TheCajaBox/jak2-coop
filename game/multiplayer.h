#pragma once

#define ASIO_STANDALONE
#include "kernel/common/kernel_types.h"
#include <websocketpp/config/asio_no_tls.hpp>
#include <websocketpp/server.hpp>
#include "common/util/json_util.h"

using websocketpp::lib::bind;

typedef websocketpp::server<websocketpp::config::asio> server;

void start_socket(int socketPort);
void connect_mp_info(u64 mpInfo, u64 selfPlayerInfo, u64 teamrunInfo, u64 teamrunLevelInfo);
void clear_mp_command();
void send_position_update();
void send_repl_connection_acknowledgement();
void connect_coop_info(u64 coopInfo);
u64 coop_send_save(u64 src, u64 size);
u64 coop_take_save(u64 dst, u64 max_size);

//extern char username[101];
