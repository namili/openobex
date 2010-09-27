/**
	\file openobex/obex.h
	OpenOBEX library - Free implementation of the Object Exchange protocol.

	Copyright (C) 1999-2000  Dag Brattli <dagb@cs.uit.no>
	Copyright (C) 1999-2000  Pontus Fuchs <pontus.fuchs@tactel.se>
	Copyright (C) 2001-2002  Jean Tourrilhes <jt@hpl.hp.com>
	Copyright (C) 2002-2006  Marcel Holtmann <marcel@holtmann.org>
	Copyright (C) 2002-2008  Christian W. Zuckschwerdt <zany@triq.net>
	Copyright (C) 2002  Dmitry Kasatkin <dmitry.kasatkin@nokia.com>
	Copyright (C) 2005  Herton Ronaldo Krzesinski <herton@conectiva.com.br>
	Copyright (C) 2005-2008  Alex Kanavin <ak@sensi.org>
	Copyright (C) 2006  Johan Hedberg <johan.hedberg@nokia.com>
	Copyright (C) 2007-2008  Hendrik Sattler <post@hendrik-sattler.de>

	OpenOBEX is free software; you can redistribute it and/or modify
	it under the terms of the GNU Lesser General Public License as
	published by the Free Software Foundation; either version 2.1 of
	the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with OpenOBEX. If not, see <http://www.gnu.org/>.
 */

#ifndef OPENOBEX_OBEX_H
#define OPENOBEX_OBEX_H

#ifdef __cplusplus
extern "C" {
#endif

#ifdef _WIN32
#include <winsock2.h>
#ifndef OPENOBEX_SYMBOL
#ifdef OPENOBEX_DLL
#define OPENOBEX_SYMBOL(retval) __declspec(dllimport) retval WINAPI
#else /* OPENOBEX_DLL */
#define OPENOBEX_SYMBOL(retval) retval WINAPI
#endif /* OPENOBEX_DLL */
#endif /* OPENOBEX_SYMBOL */

#else /* _WIN32 */
#include <sys/socket.h>
#endif /* _WIN32 */

#include <inttypes.h>

#ifndef OPENOBEX_SYMBOL
#define OPENOBEX_SYMBOL(retval) retval
#endif

struct obex;
struct obex_object;

typedef struct obex obex_t;
typedef struct obex_object obex_object_t;

typedef void (*obex_event_t)(obex_t *handle, obex_object_t *obj, int mode, int event, int obex_cmd, int obex_rsp);

#include <openobex/obex_const.h>

/*
 *  OBEX API
 */
OPENOBEX_SYMBOL(obex_t *) OBEX_Init(int transport, obex_event_t eventcb, unsigned int flags);
OPENOBEX_SYMBOL(void)     OBEX_Cleanup(obex_t *self);
OPENOBEX_SYMBOL(void)     OBEX_SetUserData(obex_t *self, void * data);
OPENOBEX_SYMBOL(void *)   OBEX_GetUserData(obex_t *self);
OPENOBEX_SYMBOL(void)     OBEX_SetUserCallBack(obex_t *self, obex_event_t eventcb, void * data);
OPENOBEX_SYMBOL(int)      OBEX_SetTransportMTU(obex_t *self, uint16_t mtu_rx, uint16_t mtu_tx_max);
OPENOBEX_SYMBOL(int)      OBEX_GetFD(obex_t *self);

OPENOBEX_SYMBOL(int)    OBEX_RegisterCTransport(obex_t *self, obex_ctrans_t *ctrans);
OPENOBEX_SYMBOL(void)   OBEX_SetCustomData(obex_t *self, void * data);
OPENOBEX_SYMBOL(void *) OBEX_GetCustomData(obex_t *self);

OPENOBEX_SYMBOL(int) OBEX_TransportConnect(obex_t *self, struct sockaddr *saddr, int addlen);
OPENOBEX_SYMBOL(int) OBEX_TransportDisconnect(obex_t *self);
OPENOBEX_SYMBOL(int) OBEX_CustomDataFeed(obex_t *self, uint8_t *inputbuf, int actual);
OPENOBEX_SYMBOL(int) OBEX_HandleInput(obex_t *self, int timeout);

OPENOBEX_SYMBOL(int)      OBEX_ServerRegister(obex_t *self, struct sockaddr *saddr, int addrlen);
OPENOBEX_SYMBOL(obex_t *) OBEX_ServerAccept(obex_t *server, obex_event_t eventcb, void * data);

OPENOBEX_SYMBOL(int) OBEX_Request(obex_t *self, obex_object_t *object);
OPENOBEX_SYMBOL(int) OBEX_CancelRequest(obex_t *self, int nice);
OPENOBEX_SYMBOL(int) OBEX_SuspendRequest(obex_t *self, obex_object_t *object);
OPENOBEX_SYMBOL(int) OBEX_ResumeRequest(obex_t *self);

OPENOBEX_SYMBOL(obex_object_t *) OBEX_ObjectNew(obex_t *self, uint8_t cmd);
OPENOBEX_SYMBOL(int)             OBEX_ObjectDelete(obex_t *self, obex_object_t *object);
OPENOBEX_SYMBOL(int)             OBEX_ObjectGetSpace(obex_t *self, obex_object_t *object, unsigned int flags);

OPENOBEX_SYMBOL(int) OBEX_ObjectAddHeader(obex_t *self, obex_object_t *object,
				    uint8_t hi, obex_headerdata_t hv, uint32_t hv_size,
				    unsigned int flags);
OPENOBEX_SYMBOL(int) OBEX_ObjectGetNextHeader(obex_t *self, obex_object_t *object,
					uint8_t *hi, obex_headerdata_t *hv, uint32_t *hv_size);
OPENOBEX_SYMBOL(int) OBEX_ObjectReParseHeaders(obex_t *self, obex_object_t *object);
OPENOBEX_SYMBOL(int) OBEX_ObjectSetRsp(obex_object_t *object, uint8_t rsp, uint8_t lastrsp);

OPENOBEX_SYMBOL(int) OBEX_ObjectGetNonHdrData(obex_object_t *object, uint8_t **buffer);
OPENOBEX_SYMBOL(int) OBEX_ObjectSetNonHdrData(obex_object_t *object, const uint8_t *buffer, unsigned int len);
OPENOBEX_SYMBOL(int) OBEX_ObjectSetHdrOffset(obex_object_t *object, unsigned int offset);
OPENOBEX_SYMBOL(int) OBEX_ObjectReadStream(obex_t *self, obex_object_t *object, const uint8_t **buf);
OPENOBEX_SYMBOL(int) OBEX_ObjectGetCommand(obex_t *self, obex_object_t *object);

OPENOBEX_SYMBOL(int) OBEX_UnicodeToChar(uint8_t *c, const uint8_t *uc, int size);
OPENOBEX_SYMBOL(int) OBEX_CharToUnicode(uint8_t *uc, const uint8_t *c, int size);

OPENOBEX_SYMBOL(char *) OBEX_ResponseToString(int rsp);
OPENOBEX_SYMBOL(void)	OBEX_SetEnableSRM(obex_object_t * object);

/*
 * TcpOBEX API (IPv4/IPv6)
 */
OPENOBEX_SYMBOL(int) TcpOBEX_ServerRegister(obex_t *self, struct sockaddr *addr, int addrlen);
OPENOBEX_SYMBOL(int) TcpOBEX_TransportConnect(obex_t *self, struct sockaddr *addr, int addrlen);

/*
 * IrOBEX API 
 */
OPENOBEX_SYMBOL(int) IrOBEX_ServerRegister(obex_t *self, const char *service);
OPENOBEX_SYMBOL(int) IrOBEX_TransportConnect(obex_t *self, const char *service);

/*
 * Bluetooth OBEX API
 */
#if !defined(bt_addr_t)
#  if defined(SOL_RFCOMM)
#    if defined(_WIN32) /* Windows */
#      define bt_addr_t BTH_ADDR
#    else /* Linux, FreeBSD, NetBSD */
#      define bt_addr_t bdaddr_t
#    endif
#  else /* no bluetooth stack available */
#    define bt_addr_t unsigned long
#  endif
#endif
OPENOBEX_SYMBOL(int) BtOBEX_ServerRegister(obex_t *self, bt_addr_t *src, uint8_t channel);
OPENOBEX_SYMBOL(int) BtOBEX_TransportConnect(obex_t *self, bt_addr_t *src, bt_addr_t *dst, uint8_t channel);

/*
 * OBEX File API
 */
OPENOBEX_SYMBOL(int) FdOBEX_TransportSetup(obex_t *self, int rfd, int wfd, int mtu, int fmt);

/*  
 * OBEX interface discovery API 
 */
OPENOBEX_SYMBOL(int)  OBEX_EnumerateInterfaces(obex_t *self);
OPENOBEX_SYMBOL(obex_interface_t *)  OBEX_GetInterfaceByIndex(obex_t *self, int i);
OPENOBEX_SYMBOL(int)  OBEX_InterfaceConnect(obex_t *self, obex_interface_t *intf);
OPENOBEX_SYMBOL(void) OBEX_FreeInterfaces(obex_t *self);

#ifdef __cplusplus
}
#endif

#endif /* OPENOBEX_OBEX_H */
