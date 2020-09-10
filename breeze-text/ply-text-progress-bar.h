/* ply-text-progress-bar.h - simple text based pulsing animation
 *
 * SPDX-FileCopyrightText: 2008 Red Hat Inc. 
 * SPDX-FileContributor: Adam Jackson <ajax@redhat.com>
 * SPDX-FileContributor: Bill Nottingham <notting@redhat.com>
 * SPDX-FileContributor: Ray Strode <rstrode@redhat.com>
 * SPDX-FileContributor: Soeren Sandmann <sandmann@redhat.com>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
#ifndef BREEZE_TEXT_PROGRESS_BAR_H
#define BREEZE_TEXT_PROGRESS_BAR_H

#include <stdbool.h>
#include <stdint.h>
#include <unistd.h>

#include "ply-event-loop.h"
#include "ply-text-display.h"

typedef struct _breeze_text_progress_bar breeze_text_progress_bar_t;

#ifndef PLY_HIDE_FUNCTION_DECLARATIONS
breeze_text_progress_bar_t *breeze_text_progress_bar_new (void);
void breeze_text_progress_bar_free (breeze_text_progress_bar_t *progress_bar);

void breeze_text_progress_bar_draw (breeze_text_progress_bar_t *progress_bar);
void breeze_text_progress_bar_show (breeze_text_progress_bar_t  *progress_bar,
                                 ply_text_display_t       *display);
void breeze_text_progress_bar_hide (breeze_text_progress_bar_t *progress_bar);

void breeze_text_progress_bar_set_percent_done (breeze_text_progress_bar_t  *progress_bar,
                                             double percent_done);

double breeze_text_progress_bar_get_percent_done (breeze_text_progress_bar_t  *progress_bar);

int breeze_text_progress_bar_get_number_of_rows (breeze_text_progress_bar_t *progress_bar);
int breeze_text_progress_bar_get_number_of_columns (breeze_text_progress_bar_t *progress_bar);
#endif

#endif /* BREEZE_TEXT_PULSER_H */
/* vim: set ts=4 sw=4 expandtab autoindent cindent cino={.5s,(0: */
