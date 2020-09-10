/* fork. doesn't include os_string and draws all blocks white.
 *
 * SPDX-FileCopyrightText: 2008 Red Hat Inc. 
 * SPDX-FileContributor: Adam Jackson <ajax@redhat.com>
 * SPDX-FileContributor: Bill Nottingham <notting@redhat.com>
 * SPDX-FileContributor: Ray Strode <rstrode@redhat.com>
 * SPDX-FileContributor: Soeren Sandmann <sandmann@redhat.com>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "ply-text-progress-bar.h"

#include <assert.h>
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <math.h>
#include <signal.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>
#include <values.h>
#include <unistd.h>
#include <wchar.h>

#include <ply-text-display.h>
#include <ply-array.h>
#include <ply-logger.h>
#include <ply-utils.h>

#include <linux/kd.h>

#ifndef FRAMES_PER_SECOND
#define FRAMES_PER_SECOND 5
#endif

#define NUMBER_OF_INDICATOR_COLUMNS 6

static char *os_string;

struct _breeze_text_progress_bar
{
  ply_text_display_t *display;

  int column, row;
  int number_of_rows;
  int number_of_columns;

  double percent_done;
  uint32_t is_hidden : 1;
};

breeze_text_progress_bar_t *
breeze_text_progress_bar_new (void)
{
  breeze_text_progress_bar_t *progress_bar;

  progress_bar = calloc (1, sizeof (breeze_text_progress_bar_t));

  progress_bar->row = 0;
  progress_bar->column = 0;
  progress_bar->number_of_columns = 0;
  progress_bar->number_of_rows = 0;

  return progress_bar;
}

void
breeze_text_progress_bar_free (breeze_text_progress_bar_t *progress_bar)
{
  if (progress_bar == NULL)
    return;

  free (progress_bar);
}

static void
get_os_string (void)
{
  os_string = "";
}

void
breeze_text_progress_bar_draw (breeze_text_progress_bar_t *progress_bar)
{
    int i, width;
    double brown_fraction, blue_fraction, white_fraction;

    if (progress_bar->is_hidden)
      return;

    width = progress_bar->number_of_columns - 2 - strlen (os_string);

    ply_text_display_set_cursor_position (progress_bar->display,
                                          progress_bar->column,
                                          progress_bar->row);

    brown_fraction = - (progress_bar->percent_done * progress_bar->percent_done) + 2 * progress_bar->percent_done;
    blue_fraction  = progress_bar->percent_done;
    white_fraction = progress_bar->percent_done * progress_bar->percent_done;

    for (i = 0; i < width; i++) {
        double f;

        f = (double) i / (double) width;
        if (f < white_fraction)
            ply_text_display_set_background_color (progress_bar->display,
                                                   PLY_TERMINAL_COLOR_WHITE);
        else if (f < blue_fraction)
            ply_text_display_set_background_color (progress_bar->display,
                                             PLY_TERMINAL_COLOR_WHITE);
        else if (f < brown_fraction)
            ply_text_display_set_background_color (progress_bar->display,
                                             PLY_TERMINAL_COLOR_WHITE);
        else
          break;

        ply_text_display_write (progress_bar->display, "%c", ' ');
    }

    ply_text_display_set_background_color (progress_bar->display,
                                           PLY_TERMINAL_COLOR_BLACK);

    if (brown_fraction > 0.5) {
        if (white_fraction > 0.875)
            ply_text_display_set_foreground_color (progress_bar->display,
                                                   PLY_TERMINAL_COLOR_WHITE);
        else if (blue_fraction > 0.66)
            ply_text_display_set_foreground_color (progress_bar->display,
                                                   PLY_TERMINAL_COLOR_WHITE);
        else
            ply_text_display_set_foreground_color (progress_bar->display,
                                                   PLY_TERMINAL_COLOR_WHITE);

        ply_text_display_set_cursor_position (progress_bar->display,
                                              progress_bar->column + width,
                                              progress_bar->row);

        ply_text_display_write (progress_bar->display, "%s", os_string);

        ply_text_display_set_foreground_color (progress_bar->display,
                                               PLY_TERMINAL_COLOR_DEFAULT);
    }
}

void
breeze_text_progress_bar_show (breeze_text_progress_bar_t  *progress_bar,
                            ply_text_display_t       *display)
{
  assert (progress_bar != NULL);

  progress_bar->display = display;

  progress_bar->number_of_rows = ply_text_display_get_number_of_rows (display);
  progress_bar->row = progress_bar->number_of_rows - 1;
  progress_bar->number_of_columns = ply_text_display_get_number_of_columns (display);
  progress_bar->column = 2;

  get_os_string ();

  progress_bar->is_hidden = false;

  breeze_text_progress_bar_draw (progress_bar);
}

void
breeze_text_progress_bar_hide (breeze_text_progress_bar_t *progress_bar)
{
  progress_bar->display = NULL;
  progress_bar->is_hidden = true;
}

void
breeze_text_progress_bar_set_percent_done (breeze_text_progress_bar_t  *progress_bar,
                                        double percent_done)
{
  progress_bar->percent_done = percent_done;
}

double
breeze_text_progress_bar_get_percent_done (breeze_text_progress_bar_t  *progress_bar)
{
  return progress_bar->percent_done;
}

int
breeze_text_progress_bar_get_number_of_columns (breeze_text_progress_bar_t *progress_bar)
{
  return progress_bar->number_of_columns;
}

int
breeze_text_progress_bar_get_number_of_rows (breeze_text_progress_bar_t *progress_bar)
{
  return progress_bar->number_of_rows;
}

/* vim: set ts=4 sw=4 expandtab autoindent cindent cino={.5s,(0: */
