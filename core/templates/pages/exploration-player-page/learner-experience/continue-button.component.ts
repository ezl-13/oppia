// Copyright 2017 The Oppia Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS-IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/**
 * @fileoverview Component for the Continue button in exploration player and
 * editor.
 */

import { Component, EventEmitter, Input, Output } from '@angular/core';
import { downgradeComponent } from '@angular/upgrade/static';

@Component({
  selector: 'oppia-continue-button',
  templateUrl: './continue-button.component.html',
  styleUrls: []
})
export class ContinueButtonComponent {
  @Input() focusLabel: string;
  @Input() isLearnAgainButton: boolean = false;
  @Output() continueButtonClick: EventEmitter<void> = new EventEmitter();
}

angular.module('oppia').directive(
  'conceptCard', downgradeComponent(
    {component: ContinueButtonComponent}));
