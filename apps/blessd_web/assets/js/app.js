// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import css from '../css/app.scss';

import "phoenix_html";

import "./datepicker";
import "./header";
import "./file";
import "./modal";
import "./message";

import MeetingOccurrenceView from "./views/meeting_occurrence";
import CustomFieldView from "./views/custom_field";
import PersonView from "./views/person";
import SessionView from "./views/session";

window.views = {
  Elixir: {
    BlessdWeb: {
      MeetingOccurrenceView: MeetingOccurrenceView,
      CustomFieldView: CustomFieldView,
      PersonView: PersonView,
      SessionView: SessionView
    }
  }
};

