import { Routes } from '@angular/router';
import { SpeechListComponent } from './speech-list/speech-list';

export const routes: Routes = [
      { path: 'home', component: SpeechListComponent }, // just placeholder for now
  { path: 'speeches', component: SpeechListComponent },
  { path: '', redirectTo: '/home', pathMatch: 'full' }
];
