clear; close all; clc;

% load US data
trus=dicomread('/Users/Lindsey/Downloads/REC00000');
trus_info=dicominfo('/Users/Lindsey/Downloads/REC00000'); %gives pixel spacing info
trus=squeeze(trus);
figure;
sliceViewer(trus,'Colormap',gray,'SliceDirection','Y');
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

figure;
sliceViewer(trus3,'Colormap',gray,'SliceDirection','X');





