import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute } from '@angular/router';
import { Speech } from '../models/speech.model';
import { SpeechService } from '../services/speech.service';

@Component({
  selector: 'app-speech-details',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './speech-details.html',
  styleUrl: './speech-details.css',
})
export class SpeechDetailsComponent implements OnInit {
  speech?: Speech;
  loading = true;
  error: string | null = null;

  constructor(
    private route: ActivatedRoute,
    private speechService: SpeechService
  ) {}

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id');
    if (id) {
      this.speechService.getSpeech(id).subscribe({
        next: (data) => {
          this.speech = data;
          this.loading = false;   // ✅ stop loading on success
        },
        error: (err) => {
          this.error = 'Failed to load speech';
          console.error(err);
          this.loading = false;   // ✅ stop loading on error
        },
      });
    } else {
      this.error = 'No ID provided';
      this.loading = false;
    }
  }
}
