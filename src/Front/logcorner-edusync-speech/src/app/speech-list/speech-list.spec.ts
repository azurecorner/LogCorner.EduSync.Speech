import { ComponentFixture, TestBed } from '@angular/core/testing';

import { SpeechList } from './speech-list';

describe('SpeechList', () => {
  let component: SpeechList;
  let fixture: ComponentFixture<SpeechList>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [SpeechList]
    })
    .compileComponents();

    fixture = TestBed.createComponent(SpeechList);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
