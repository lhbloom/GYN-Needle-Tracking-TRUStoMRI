% write image in .mat to dicom in MR specification
% Manually change description with different phases

clear; close all; clc;

% load US data
trus=dicomread('/Users/Lindsey/Downloads/Needle-Tracking/Manuscript Files/12_01_LDR/123456/20231201/141354/3DDATA/REC00000');
trus_info=dicominfo('/Users/Lindsey/Downloads/Needle-Tracking/Manuscript Files/12_01_LDR/123456/20231201/141354/3DDATA/REC00000'); %gives pixel spacing info
trus=squeeze(trus);
figure;
sliceViewer(trus,'Colormap',gray,'SliceDirection','X');
%%
%pre-processing and visualization
trus2=permute(trus,[3 1 2]); % permute command changes orientation of axis
figure;
sliceViewer(trus2,'Colormap',gray,'SliceDirection','Y');

%%
trus3 = flip(trus2,3); %all we needed to do is choose axis to flip manually so I used the flip command and specified axis 3
trus4= fliplr(trus3);

%Z is axial
%Y is coronal
%X is sagittal

%figure;
sliceViewer(trus3,'Colormap',gray,'SliceDirection','X');
% Assume an image volume
% Im = permute(EOIvol,[2 1 3]); % make sure it follows DICOM coordinate system
Im =  trus4;

% % load the format for MR
Header = dicominfo('/Users/Lindsey/Downloads/Needle-Tracking/Manuscript Files/USCT Registration/DicomHeader_CT.dcm');
Header0 = Header;
%%
% 
% load the format for CT
% Header = dicominfo('D:\DCE-MRI\DICOMdata\FourD_MR-CT\FourD_CT_UnprocessedData\slice (1).dcm');
% Header0 = Header;

% specify the voxel size in mm
dicomInF = trus_info;
voxS(3) = dicomInF.SliceThickness;
voxS(1) = dicomInF.PixelSpacing(1);
voxS(2) = dicomInF.PixelSpacing(1);
% specify matrix size
[sizey,sizex] = size(Im(:,:,1));
TotSliceN = size(Im,3);

Header.PixelSpacing = [voxS(2);voxS(1)]; % in mm
Header.SliceThickness = voxS(3);
Header.Rows = sizey;
Header.Columns = sizex;
Header.Width = sizey;
Header.Height = sizex;
Header.AcquisitionDate = '20231025';

Header.StudyInstanceUID = dicomuid;% unique ID
Header.SeriesInstanceUID = dicomuid; % must be different for different volume
% ----------
% Header.FrameOfReferenceUID = dicomuid;  % if want DICOM connection, two volumes must have same FOR
% different phase volumes must have same FOR UID
% ----------


Header.PatientOrientation =' HFS';
Header.ImageOrientationPatient = [1;0;0;0;1;0];

Header.InstanceCreationDate = datestr(date,'yyyymmdd');
Header.InstanceCreationTime = '101010';
Header.StudyDate = datestr(date,'yyyymmdd');
Header.SeriesDate = datestr(date,'yyyymmdd');
Header.ContentDate = datestr(date,'yyyymmdd');
Header.StationName='MR_Matlab';
Header.StudyDescription = 'CTtest';
Header.SeriesDescription = 'CTtest';
%Header.PatientID = 'D1628666';
Header.PatientID = '16DEC2021';
Header.PatientName.FamilyName = 'Phantom';
Header.PatientName.GivenName = '3DGYN';
Header.PatientName.MiddleName = '';
Header.StudyID = '0303';
Header.PhysicianOfRecord = '';
Header.PatientBirthDate = '';
Header.PatientSex = '';
Header.EthnicGroup = '';


% % required for importing into Eclipse
% headerSlices.ImageType = 'ORIGINAL\PRIMARY\AXIAL';
% headerSlices.RescaleIntercept = -1024;
% headerSlices.RescaleSlope = 1;



% write
saving_pathname =uigetdir('C:\', 'Please choose the directory you want to save DICOM files');
h = waitbar(0,'Exporting DICOM. Please wait...');
for iSlice = 1:TotSliceN
        % required for importing into Velocity
        Header.ImagePositionPatient = [-sizey*voxS(2)/2; -sizex*voxS(1)/2; iSlice*voxS(3)];
%         Header.ImagePositionPatient = [-sizey*voxS(2)/2; -sizex*voxS(1)/2; (TotSliceN-iSlice)*voxS(3)];
        Header.SliceLocation = Header.ImagePositionPatient(3);
        Header.InstanceNumber=iSlice;
        % added Apr 12, 2016
        sopUID = dicomuid;
        Header.SOPInstanceUID = sopUID;
        Header.MediaStorageSOPInstanceUID = sopUID;
        
        % use if MR
        str=strcat(saving_pathname,'\CT-',num2str(Header.StudyID),'-',Header.SeriesDescription,'-',num2str(Header.SliceLocation*10^4 + 10^7),'.dcm');
        
%         % use if CT
%         str=strcat(saving_pathname,'\CT-',num2str(Header.StudyID),'-',Header.SeriesDescription,'-',num2str(Header.SliceLocation*10^4),'.dcm');
        
%         DispImg = Im(:,:,iSlice)-30740-2000;  % added on 20161229
        DispImg = Im(:,:,iSlice);
        DispImg=int16(DispImg);
        dicomwrite(DispImg,str,Header);
        waitbar((iSlice)/TotSliceN);
end
close(h);

%%
% for iPhase = 1:length(varName)
%     currVolume = imgData.(varName{iPhase});
%     voxN = size(currVolume);
%     savePath = ['E:\DVF improvement\DIR-LAB\Data\dcm\for Eclipse\' headerSlices.PatientID '\' varName{iPhase}];
%     mkdir(savePath);
%     % required for importing into Velocity
%     headerSlices.SeriesDescription = varName{iPhase};
%     % required for importing into Eclipse
%     headerSlices.SeriesInstanceUID = dicomuid;
%     headerSlices.FrameOfReferenceUID = dicomuid;
%     for iSlice = 1:voxN(3)
%         % required for importing into Velocity
%         headerSlices.ImagePositionPatient = [-voxN(1)*voxS(1)/2;-voxN(1)*voxS(1)/2;(voxN(3)-iSlice)*voxS(3)];
%         headerSlices.SliceLocation = headerSlices.ImagePositionPatient(3);
%         % required for importing into Eclipse
%         sopUID = dicomuid;
%         headerSlices.SOPInstanceUID = sopUID;
%         headerSlices.MediaStorageSOPInstanceUID = sopUID;
%         dicomwrite(squeeze(currVolume(:,:,iSlice)),[savePath '\' sprintf('slice(%g).dcm',iSlice)],headerSlices);
%     end
% end
% % 


















