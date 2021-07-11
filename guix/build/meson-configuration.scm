;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2021 Maxime Devos <maximedevos@telenet.be>
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (guix build meson-configuration)
  #:use-module (ice-9 match)
  #:export (write-section-header write-assignment
            write-assignments make-machine-alist
            configuration-port))

;; Commentary:
;;
;; Utilities for generating a ‘Cross build definition file’ for
;; the Meson build system.  Configuration values are currently
;; never escaped.  In practice this is unlikely to be a problem
;; in the build environment.
;;
;; Code:

(define configuration-port
  (fluid->parameter (make-unbound-fluid)))

(define (write-section-header section-name)
  "Write a section header for section named SECTION-NAME
to the configuration port."
  (format (configuration-port) "[~a]~%" section-name))

(define (write-assignment key value)
  "Write an assignment of VALUE to KEY to the configuration
port.  VALUE must be a string (without any special characters
such as quotes), a boolean or an integer.  Lists are currently
not supported"
  (define port (configuration-port))
  (match value
    ((? string?)
     (format port "~a = '~a'~%" key value))
    ((? integer?)
     (format port "~a = ~a~%" key value))
    (#f
     (format port "~a = true~%" key))
    (#t
     (format port "~a = false~%" key))))

(define* (write-assignments alist)
  "Write the assignments in ALIST, an association list,
to the configuration port."
  (for-each (match-lambda
              ((key . value)
               (write-assignment key value)))
            alist))

(define* (make-machine-alist #:key system cpu-family cpu endian)
  "Make an association list for the [host_machine] section."
  `((system . ,system)
    (cpu-family . ,cpu-family)
    (cpu . ,cpu)
    (endian . ,endian)))
