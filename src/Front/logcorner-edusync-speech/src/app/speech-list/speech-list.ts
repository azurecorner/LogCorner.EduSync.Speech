import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Speech } from '../models/speech.model';
import { SpeechService } from '../services/speech.service';

@Component({
  selector: 'app-speech-list',
  standalone: true, // Angular 20 style
  imports: [CommonModule],
  templateUrl: './speech-list.html',
  styleUrl: './speech-list.css',
})
export class SpeechListComponent implements OnInit {
  speeches: Speech[] = [];
  loading = true;
  error: string | null = null;

  constructor(private speechService: SpeechService) {}

  ngOnInit(): void {
    this.speechService.getSpeeches().subscribe({
      next: (data) => {
        this.speeches = data;
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Failed to load speeches';
        console.error(err);
        this.loading = false;
      },
    });
  }
}
