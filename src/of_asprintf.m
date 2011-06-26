/*
 * Copyright (c) 2008, 2009, 2010, 2011
 *   Jonathan Schleifer <js@webkeks.org>
 *
 * All rights reserved.
 *
 * This file is part of ObjFW. It may be distributed under the terms of the
 * Q Public License 1.0, which can be found in the file LICENSE.QPL included in
 * the packaging of this file.
 *
 * Alternatively, it may be distributed under the terms of the GNU General
 * Public License, either version 2 or 3, which can be found in the file
 * LICENSE.GPLv2 or LICENSE.GPLv3 respectively included in the packaging of this
 * file.
 */

#include "config.h"

#define _GNU_SOURCE
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <stdbool.h>
#include <wchar.h>

#import "OFString.h"
#import "OFAutoreleasePool.h"
#import "asprintf.h"

#import "macros.h"

#define MAX_SUBFORMAT_LEN 64

struct context {
	const char *format;
	size_t formatLen;
	char subformat[MAX_SUBFORMAT_LEN + 1];
	size_t subformatLen;
	va_list arguments;
	char *buffer;
	size_t bufferLen;
	size_t i, last;
	enum {
		STATE_STRING,
		STATE_FORMAT_FLAGS,
		STATE_FORMAT_FIELD_WIDTH,
		STATE_FORMAT_LENGTH_MODIFIER,
		STATE_FORMAT_CONVERSION_SPECIFIER
	} state;
	enum {
		LENGTH_MODIFIER_NONE,
		LENGTH_MODIFIER_HH,
		LENGTH_MODIFIER_H,
		LENGTH_MODIFIER_L,
		LENGTH_MODIFIER_LL,
		LENGTH_MODIFIER_J,
		LENGTH_MODIFIER_Z,
		LENGTH_MODIFIER_T,
		LENGTH_MODIFIER_CAPITAL_L
	} lengthModifier;
};

static bool
appendString(struct context *ctx, const char *append, size_t appendLen)
{
	char *nBuf;

	if (appendLen == 0)
		return true;

	if ((nBuf = realloc(ctx->buffer,
	    ctx->bufferLen + appendLen + 1)) == NULL)
		return false;

	memcpy(nBuf + ctx->bufferLen, append, appendLen);

	ctx->buffer = nBuf;
	ctx->bufferLen += appendLen;

	return true;
}

static bool
appendSubformat(struct context *ctx, const char *subformat, size_t subformatLen)
{
	if (ctx->subformatLen + subformatLen > MAX_SUBFORMAT_LEN)
		return false;

	memcpy(ctx->subformat + ctx->subformatLen, subformat, subformatLen);
	ctx->subformatLen += subformatLen;
	ctx->subformat[ctx->subformatLen] = 0;

	return true;
}

static bool
stringState(struct context *ctx)
{
	if (ctx->format[ctx->i] == '%') {
		if (ctx->i > 0)
			if (!appendString(ctx, ctx->format + ctx->last,
			    ctx->i - ctx->last))
				return false;

		if (!appendSubformat(ctx, ctx->format + ctx->i, 1))
			return false;

		ctx->last = ctx->i + 1;
		ctx->state = STATE_FORMAT_FLAGS;
	}

	return true;
}

static bool
formatFlagsState(struct context *ctx)
{
	switch (ctx->format[ctx->i]) {
	case '-':
	case '+':
	case ' ':
	case '#':
	case '0':
		if (!appendSubformat(ctx, ctx->format + ctx->i, 1))
			return false;

		break;
	default:
		ctx->state = STATE_FORMAT_FIELD_WIDTH;
		ctx->i--;

		break;
	}

	return true;
}

static bool
formatFieldWidthState(struct context *ctx)
{
	if ((ctx->format[ctx->i] >= '0' && ctx->format[ctx->i] <= '9') ||
	    ctx->format[ctx->i] == '*' || ctx->format[ctx->i] == '.') {
		if (!appendSubformat(ctx, ctx->format + ctx->i, 1))
			return false;
	} else {
		ctx->state = STATE_FORMAT_LENGTH_MODIFIER;
		ctx->i--;
	}

	return true;
}

static bool
formatLengthModifierState(struct context *ctx)
{
	/* Only one allowed */
	switch (ctx->format[ctx->i]) {
	case 'h': /* and also hh */
		if (ctx->formatLen > ctx->i + 1 &&
		    ctx->format[ctx->i + 1] == 'h') {
			if (!appendSubformat(ctx, ctx->format + ctx->i, 2))
				return false;

			ctx->i++;
			ctx->lengthModifier = LENGTH_MODIFIER_HH;
		} else {
			if (!appendSubformat(ctx, ctx->format + ctx->i, 1))
				return false;

			ctx->lengthModifier = LENGTH_MODIFIER_H;
		}

		break;
	case 'l': /* and also ll */
		if (ctx->formatLen > ctx->i + 1 &&
		    ctx->format[ctx->i + 1] == 'l') {
#ifndef _WIN32
			if (!appendSubformat(ctx, ctx->format + ctx->i, 2))
				return false;
#else
			if (!appendSubformat(ctx, "I64", 3))
				return false;
#endif

			ctx->i++;
			ctx->lengthModifier = LENGTH_MODIFIER_LL;
		} else {
			if (!appendSubformat(ctx, ctx->format + ctx->i, 1))
				return false;

			ctx->lengthModifier = LENGTH_MODIFIER_L;
		}

		break;
	case 'j':
#ifndef _WIN32
		if (!appendSubformat(ctx, ctx->format + ctx->i, 1))
			return false;
#else
		if (!appendSubformat(ctx, "I64", 3))
			return false;
#endif

		ctx->lengthModifier = LENGTH_MODIFIER_J;

		break;
	case 'z':
		if (!appendSubformat(ctx, ctx->format + ctx->i, 1))
			return false;

		ctx->lengthModifier = LENGTH_MODIFIER_Z;

		break;
	case 't':
		if (!appendSubformat(ctx, ctx->format + ctx->i, 1))
			return false;

		ctx->lengthModifier = LENGTH_MODIFIER_T;

		break;
	case 'L':
		if (!appendSubformat(ctx, ctx->format + ctx->i, 1))
			return false;

		ctx->lengthModifier = LENGTH_MODIFIER_CAPITAL_L;

		break;
#ifdef _WIN32
	case 'I': /* win32 strangeness (I64 instead of ll or j) */
		if (ctx->formatLen > ctx->i + 2 &&
		    ctx->format[ctx->i + 1] == '6' &&
		    ctx->format[ctx->i + 2] == '4') {
			if (!appendSubformat(ctx, ctx->format + ctx->i, 3))
				return false;

			ctx->i += 2;
			ctx->lengthModifier = LENGTH_MODIFIER_LL;
		} else
			ctx->i--;

		break;
#endif
#ifdef OF_IOS
	case 'q': /* iOS uses this for PRI?64 */
		if (!appendSubformat(ctx, ctx->format + ctx->i, 1))
			return false;

		ctx->lengthModifier = LENGTH_MODIFIER_LL;

		break;
#endif
	default:
		ctx->i--;

		break;
	}

	ctx->state = STATE_FORMAT_CONVERSION_SPECIFIER;
	return true;
}

static bool
formatConversionSpecifierState(struct context *ctx)
{
	char *tmp = NULL;
	int tmpLen = 0;

	if (!appendSubformat(ctx, ctx->format + ctx->i, 1))
		return false;

	switch (ctx->format[ctx->i]) {
	case '@':;
		OFAutoreleasePool *pool;

		ctx->subformat[ctx->subformatLen - 1] = 's';

		@try {
			pool = [[OFAutoreleasePool alloc] init];
		} @catch (id e) {
			[e release];
			return false;
		}

		@try {
			id object;

			if ((object = va_arg(ctx->arguments, id)) != nil)
				tmpLen = asprintf(&tmp, ctx->subformat,
				    [[object description] cString]);
			else
				tmpLen = asprintf(&tmp, ctx->subformat,
				    "(nil)");
		} @catch (id e) {
			free(ctx->buffer);
			@throw e;
		} @finally {
			[pool release];
		}

		break;
	case 'd':
	case 'i':
		switch (ctx->lengthModifier) {
		case LENGTH_MODIFIER_NONE:
		case LENGTH_MODIFIER_HH:
		case LENGTH_MODIFIER_H:
			tmpLen = asprintf(&tmp, ctx->subformat,
			    va_arg(ctx->arguments, int));
			break;
		case LENGTH_MODIFIER_L:
			tmpLen = asprintf(&tmp, ctx->subformat,
			    va_arg(ctx->arguments, long));
			break;
		case LENGTH_MODIFIER_LL:
			tmpLen = asprintf(&tmp, ctx->subformat,
			    va_arg(ctx->arguments, long long));
			break;
		case LENGTH_MODIFIER_J:
			tmpLen = asprintf(&tmp, ctx->subformat,
			    va_arg(ctx->arguments, intmax_t));
			break;
		case LENGTH_MODIFIER_Z:
			tmpLen = asprintf(&tmp, ctx->subformat,
			    va_arg(ctx->arguments, ssize_t));
			break;
		case LENGTH_MODIFIER_T:
			tmpLen = asprintf(&tmp, ctx->subformat,
			    va_arg(ctx->arguments, ptrdiff_t));
			break;
		default:
			return false;
		}

		break;
	case 'o':
	case 'u':
	case 'x':
	case 'X':
		switch (ctx->lengthModifier) {
		case LENGTH_MODIFIER_NONE:
		case LENGTH_MODIFIER_HH:
		case LENGTH_MODIFIER_H:
			tmpLen = asprintf(&tmp, ctx->subformat,
			    va_arg(ctx->arguments, unsigned int));
			break;
		case LENGTH_MODIFIER_L:
			tmpLen = asprintf(&tmp, ctx->subformat,
			    va_arg(ctx->arguments, unsigned long));
			break;
		case LENGTH_MODIFIER_LL:
			tmpLen = asprintf(&tmp, ctx->subformat,
			    va_arg(ctx->arguments, unsigned long long));
			break;
		case LENGTH_MODIFIER_J:
			tmpLen = asprintf(&tmp, ctx->subformat,
			    va_arg(ctx->arguments, uintmax_t));
			break;
		case LENGTH_MODIFIER_Z:
			tmpLen = asprintf(&tmp, ctx->subformat,
			    va_arg(ctx->arguments, size_t));
			break;
		case LENGTH_MODIFIER_T:
			tmpLen = asprintf(&tmp, ctx->subformat,
			    va_arg(ctx->arguments, ptrdiff_t));
			break;
		default:
			return false;
		}

		break;
	case 'f':
	case 'F':
	case 'e':
	case 'E':
	case 'g':
	case 'G':
	case 'a':
	case 'A':
		switch (ctx->lengthModifier) {
		case LENGTH_MODIFIER_NONE:
		case LENGTH_MODIFIER_L:
			tmpLen = asprintf(&tmp, ctx->subformat,
			    va_arg(ctx->arguments, double));
			break;
		case LENGTH_MODIFIER_CAPITAL_L:
			tmpLen = asprintf(&tmp, ctx->subformat,
			    va_arg(ctx->arguments, long double));
			break;
		default:
			return false;
		}

		break;
	case 'c':
		switch (ctx->lengthModifier) {
		case LENGTH_MODIFIER_NONE:
			tmpLen = asprintf(&tmp, ctx->subformat,
			    va_arg(ctx->arguments, int));
			break;
		case LENGTH_MODIFIER_L:
#if WINT_MAX >= INT_MAX
			tmpLen = asprintf(&tmp, ctx->subformat,
			    va_arg(ctx->arguments, wint_t));
#else
			tmpLen = asprintf(&tmp, ctx->subformat,
			    va_arg(ctx->arguments, int));
#endif
			break;
		default:
			return false;
		}

		break;
	case 's':
		switch (ctx->lengthModifier) {
		case LENGTH_MODIFIER_NONE:
			tmpLen = asprintf(&tmp, ctx->subformat,
			    va_arg(ctx->arguments, const char*));
			break;
		case LENGTH_MODIFIER_L:
			tmpLen = asprintf(&tmp, ctx->subformat,
			    va_arg(ctx->arguments, const wchar_t*));
			break;
		default:
			return false;
		}

		break;
	case 'p':
		if (ctx->lengthModifier != LENGTH_MODIFIER_NONE)
			return false;

		tmpLen = asprintf(&tmp, ctx->subformat,
		    va_arg(ctx->arguments, void*));

		break;
	case 'n':
		switch (ctx->lengthModifier) {
		case LENGTH_MODIFIER_NONE:
			*va_arg(ctx->arguments, int*) = (int)ctx->bufferLen;
			break;
		case LENGTH_MODIFIER_HH:
			*va_arg(ctx->arguments, signed char*) =
			    (signed char)ctx->bufferLen;
			break;
		case LENGTH_MODIFIER_H:
			*va_arg(ctx->arguments, short*) = (short)ctx->bufferLen;
			break;
		case LENGTH_MODIFIER_L:
			*va_arg(ctx->arguments, long*) = (long)ctx->bufferLen;
			break;
		case LENGTH_MODIFIER_LL:
			*va_arg(ctx->arguments, long long*) =
			    (long long)ctx->bufferLen;
			break;
		case LENGTH_MODIFIER_J:
			*va_arg(ctx->arguments, intmax_t*) =
			    (intmax_t)ctx->bufferLen;
			break;
		case LENGTH_MODIFIER_Z:
			*va_arg(ctx->arguments, size_t*) = ctx->bufferLen;
			break;
		case LENGTH_MODIFIER_T:
			*va_arg(ctx->arguments, ptrdiff_t*) =
			    (ptrdiff_t)ctx->bufferLen;
			break;
		default:
			return false;
		}

		break;
	case '%':
		if (ctx->lengthModifier != LENGTH_MODIFIER_NONE)
			return false;

		if (!appendString(ctx, "%", 1))
			return false;

		break;
	default:
		return false;
	}

	if (tmpLen == -1)
		return false;

	if (tmp != NULL) {
		if (!appendString(ctx, tmp, tmpLen)) {
			free(tmp);
			return false;
		}

		free(tmp);
	}

	memset(ctx->subformat, 0, MAX_SUBFORMAT_LEN);
	ctx->subformatLen = 0;
	ctx->lengthModifier = LENGTH_MODIFIER_NONE;

	ctx->last = ctx->i + 1;
	ctx->state = STATE_STRING;

	return true;
}

static bool (*states[])(struct context*) = {
	stringState,
	formatFlagsState,
	formatFieldWidthState,
	formatLengthModifierState,
	formatConversionSpecifierState
};

int
of_vasprintf(char **cString, const char *format, va_list arguments)
{
	struct context ctx;

	ctx.format = format;
	ctx.formatLen = strlen(format);
	memset(ctx.subformat, 0, MAX_SUBFORMAT_LEN + 1);
	ctx.subformatLen = 0;
	va_copy(ctx.arguments, arguments);
	ctx.bufferLen = 0;
	ctx.last = 0;
	ctx.state = STATE_STRING;
	ctx.lengthModifier = LENGTH_MODIFIER_NONE;

	if ((ctx.buffer = malloc(1)) == NULL)
		return -1;

	for (ctx.i = 0; ctx.i < ctx.formatLen; ctx.i++) {
		if (!states[ctx.state](&ctx)) {
			free(ctx.buffer);
			return -1;
		}
	}

	if (ctx.state != STATE_STRING) {
		free(ctx.buffer);
		return -1;
	}

	if (!appendString(&ctx, ctx.format + ctx.last,
	    ctx.formatLen - ctx.last)) {
		free(ctx.buffer);
		return -1;
	}

	ctx.buffer[ctx.bufferLen] = 0;

	*cString = ctx.buffer;
	return (ctx.bufferLen <= INT_MAX ? (int)ctx.bufferLen : -1);
}

int
of_asprintf(char **cString, const char *format, ...)
{
	va_list arguments;
	int ret;

	va_start(arguments, format);
	ret = of_vasprintf(cString, format, arguments);
	va_end(arguments);

	return ret;
}
