package com.bwvr.backend.service;

import java.io.IOException;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import static org.mockito.ArgumentMatchers.any;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mock.web.MockMultipartFile;

import com.bwvr.backend.entity.BwvrReport;
import com.bwvr.backend.entity.BwvrReportImage;
import com.bwvr.backend.entity.BwvrReportValue;
import com.bwvr.backend.entity.BwvrTemplate;
import com.bwvr.backend.repository.ReportImageRepository;
import com.bwvr.backend.repository.ReportRepository;
import com.bwvr.backend.repository.ReportValueRepository;

@ExtendWith(MockitoExtension.class)
@SuppressWarnings("null")
class ReportImageServiceTest {

    @Mock
    ReportImageRepository reportImageRepository;
    @Mock
    ReportRepository reportRepository;
    @Mock
    ReportValueRepository reportValueRepository;

    @InjectMocks
    ReportImageService reportImageService;

    private BwvrReport report;
    private MockMultipartFile mockFile;

    @BeforeEach
    void setUp() {
        BwvrTemplate template = BwvrTemplate.builder()
                .templateId(1L).templateName("T1").isActive("Y").build();
        report = BwvrReport.builder()
                .reportId(10L).template(template).isDeleted("N").build();

        mockFile = new MockMultipartFile(
                "file", "photo.jpg", "image/jpeg", new byte[]{1, 2, 3});
    }

    // ── saveImage ─────────────────────────────────────────────────────────────
    @Test
    void saveImage_createsImageRecord() throws IOException {
        when(reportRepository.findById(10L)).thenReturn(Optional.of(report));
        when(reportValueRepository.findByReport_ReportIdAndPlaceholderKey(10L, "IMG_FRONT"))
                .thenReturn(Optional.empty());
        when(reportImageRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        BwvrReportImage saved = reportImageService.saveImage(10L, "IMG_FRONT", mockFile);

        assertThat(saved.getPlaceholderKey()).isEqualTo("IMG_FRONT");
        assertThat(saved.getImageData()).isEqualTo(new byte[]{1, 2, 3});
        assertThat(saved.getFileName()).isEqualTo("photo.jpg");
        assertThat(saved.getContentType()).isEqualTo("image/jpeg");

        verify(reportImageRepository).deleteByReportReportIdAndPlaceholderKey(10L, "IMG_FRONT");
    }

    @Test
    void saveImage_updatesExistingReportValue() throws IOException {
        BwvrReportValue val = BwvrReportValue.builder()
                .valueId(1L).placeholderKey("IMG_FRONT")
                .imageFilePath("/old/path.jpg").build();

        when(reportRepository.findById(10L)).thenReturn(Optional.of(report));
        when(reportValueRepository.findByReport_ReportIdAndPlaceholderKey(10L, "IMG_FRONT"))
                .thenReturn(Optional.of(val));
        when(reportValueRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
        when(reportImageRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        reportImageService.saveImage(10L, "IMG_FRONT", mockFile);

        ArgumentCaptor<BwvrReportValue> captor = ArgumentCaptor.forClass(BwvrReportValue.class);
        verify(reportValueRepository).save(captor.capture());
        assertThat(captor.getValue().getImageData()).isEqualTo(new byte[]{1, 2, 3});
        assertThat(captor.getValue().getImageFilePath()).isNull(); // cleared
        assertThat(captor.getValue().getImageOriginalName()).isEqualTo("photo.jpg");
    }

    @Test
    void saveImage_reportNotFound_throws() {
        when(reportRepository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> reportImageService.saveImage(99L, "IMG_FRONT", mockFile))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Report not found");
    }

    // ── getImage ─────────────────────────────────────────────────────────────
    @Test
    void getImage_found() {
        BwvrReportImage image = new BwvrReportImage();
        image.setPlaceholderKey("IMG_FRONT");
        when(reportImageRepository.findByReportReportIdAndPlaceholderKey(10L, "IMG_FRONT"))
                .thenReturn(Optional.of(image));

        BwvrReportImage result = reportImageService.getImage(10L, "IMG_FRONT");
        assertThat(result.getPlaceholderKey()).isEqualTo("IMG_FRONT");
    }

    @Test
    void getImage_notFound_throws() {
        when(reportImageRepository.findByReportReportIdAndPlaceholderKey(10L, "IMG_MISSING"))
                .thenReturn(Optional.empty());

        assertThatThrownBy(() -> reportImageService.getImage(10L, "IMG_MISSING"))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Image not found");
    }
}

