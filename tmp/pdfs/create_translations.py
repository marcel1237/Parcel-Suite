from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY, TA_LEFT, TA_RIGHT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import (BaseDocTemplate, Frame, KeepTogether, PageBreak,
    PageTemplate, Paragraph, Spacer, Table, TableStyle)
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfbase import pdfmetrics
from pathlib import Path

OUT = Path('output/pdf')
OUT.mkdir(parents=True, exist_ok=True)
W, H = A4

pdfmetrics.registerFont(TTFont('DejaVu', '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'))
pdfmetrics.registerFont(TTFont('DejaVu-Bold', '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'))

styles = getSampleStyleSheet()
BODY = ParagraphStyle('body', fontName='DejaVu', fontSize=9.2, leading=12.1, alignment=TA_JUSTIFY, spaceAfter=7)
SMALL = ParagraphStyle('small', fontName='DejaVu', fontSize=6.5, leading=8)
TINY = ParagraphStyle('tiny', fontName='DejaVu', fontSize=5.5, leading=6.8)
TITLE = ParagraphStyle('title', fontName='DejaVu-Bold', fontSize=14, leading=17, alignment=TA_CENTER, spaceAfter=16)
SUBTITLE = ParagraphStyle('subtitle', fontName='DejaVu-Bold', fontSize=9, leading=11, alignment=TA_CENTER, spaceAfter=8)
LABEL = ParagraphStyle('label', fontName='DejaVu-Bold', fontSize=7.2, leading=8.5)
CELL = ParagraphStyle('cell', fontName='DejaVu', fontSize=6.2, leading=7.4)
CELL_B = ParagraphStyle('cellb', fontName='DejaVu-Bold', fontSize=6.2, leading=7.4)

def header(canvas, doc, issued):
    canvas.saveState()
    canvas.setFillColor(colors.HexColor('#f7d600'))
    canvas.rect(20*mm, H-39*mm, W-40*mm, 30*mm, fill=1, stroke=0)
    canvas.setFillColor(colors.black)
    canvas.setFont('DejaVu-Bold', 13)
    canvas.drawString(28*mm, H-25*mm, 'UNIASSELVI')
    canvas.setFont('DejaVu-Bold', 9.5)
    canvas.drawRightString(W-25*mm, H-18*mm, 'LEONARDO DA VINCI UNIVERSITY CENTER')
    canvas.drawRightString(W-25*mm, H-23*mm, 'LEONARDO DA VINCI EDUCATIONAL SOCIETY S/S LTDA')
    canvas.setFont('DejaVu', 6.8)
    canvas.drawRightString(W-25*mm, H-28*mm, 'Reaccredited by Ordinance No. 876 of November 28, 2025, published in the Federal Official Gazette')
    canvas.drawRightString(W-25*mm, H-32*mm, 'of December 1, 2025, section 1, pages 98-99.')
    canvas.drawRightString(W-25*mm, H-36*mm, '79 Doutor Pedrinho Street - Rio Morto - ZIP 89082-262 - Indaial/SC | Phone: +55 (47) 3281-9000')
    canvas.setFont('DejaVu', 6.5)
    canvas.drawRightString(W-20*mm, H-45*mm, f'Issue date: {issued}')
    canvas.setFillColor(colors.HexColor('#555555'))
    canvas.setFont('DejaVu-Bold', 6.3)
    canvas.drawCentredString(W/2, 8*mm, 'ENGLISH TRANSLATION - ORIGINAL DOCUMENT ISSUED IN PORTUGUESE')
    canvas.restoreState()

def footer_signature():
    return Table([[Paragraph('Digitally signed using an ICP-Brasil certificate by:<br/><b>Rodrigo Murched Botelho</b><br/>CPF: 370.667.348-74<br/>Verify at https://validar.iti.gov.br/', SMALL)]], colWidths=[88*mm], style=[('BOX',(0,0),(-1,-1),0.35,colors.HexColor('#999999')),('BACKGROUND',(0,0),(-1,-1),colors.HexColor('#f7f7f7')),('LEFTPADDING',(0,0),(-1,-1),5),('RIGHTPADDING',(0,0),(-1,-1),5),('TOPPADDING',(0,0),(-1,-1),4),('BOTTOMPADDING',(0,0),(-1,-1),4)])

def auth_block(code):
    return Table([[Paragraph('<b>Authentication Code</b><br/>'+code, SMALL)], [Paragraph('To verify authenticity, visit validador.vitru.com.br and select the document authenticity verification option.', TINY)]], colWidths=[92*mm], style=[('BACKGROUND',(0,0),(-1,0),colors.HexColor('#d0d0d0')),('ALIGN',(0,0),(-1,-1),'CENTER'),('BOX',(0,0),(-1,0),0.3,colors.grey),('TOPPADDING',(0,0),(-1,-1),3),('BOTTOMPADDING',(0,0),(-1,-1),3)])

def make_doc(path, issued, auth, story, pages=1):
    def onpage(c,d): header(c,d,issued)
    doc = BaseDocTemplate(str(path), pagesize=A4, leftMargin=22*mm, rightMargin=22*mm, topMargin=53*mm, bottomMargin=15*mm)
    frame = Frame(doc.leftMargin, doc.bottomMargin, doc.width, doc.height, id='main')
    doc.addPageTemplates(PageTemplate(id='all', frames=[frame], onPage=onpage))
    doc.build([auth_block(auth), Spacer(1,12*mm)] + story)

coef_story = [
    Paragraph('ACADEMIC PERFORMANCE COEFFICIENT CERTIFICATE', TITLE),
    Paragraph('We hereby certify, for all due purposes, that <b>Marcel Aparecido de Andrade</b>, identity document (RG) No. /, CPF No. 363.915.538-66, and student registration No. 37730449, is regularly enrolled in the 3rd semester/module of the <b>Higher Technology Degree in Systems Analysis and Development</b> in the 2026/2 academic term, from June 30, 2026 through December 31, 2026, under a semester-based system, in the Distance Education / Flexible Hybrid format. The on-site support center is located in PRAIA GRANDE/SP.', BODY),
    Paragraph('We further certify that the program comprises 27 courses, of which 17.42% (seventeen point forty-two percent) have been completed to date, with an academic performance coefficient of <b>9.21</b> (nine point twenty-one) on a scale from 0.0 to 10.0.', BODY),
    Paragraph('Academic performance is evaluated by course and is based on attendance, which must be at least 75%, and an achievement grade equal to or greater than 7.0 (seven).', BODY),
    Paragraph('The program has a total workload of 2,067 hours, lasts 5 semesters, and is recognized under Ministry of Education Ordinance No. 155 of June 21, 2023, published in Federal Official Gazette No. 117, Section 1, page 241, on June 22, 2023.', BODY),
    Spacer(1,6*mm), Paragraph('Indaial/SC, August 13, 2026.', ParagraphStyle('date', parent=BODY, alignment=TA_RIGHT)), Spacer(1,6*mm), footer_signature()
]
make_doc(OUT/'Academic_Performance_Coefficient_Third_Semester_EN.pdf','August 13, 2026 - 06:05 AM','2026081381337730449000000000000402184052',coef_story)

courses = [
 ('Professional Immersion: Artificial Intelligence (173470) FLD6862895<br/><font size="5">Wednesday evening, 7:00 PM-8:30 PM</font>','11/08/2026','12/12/2026'),
 ('Object-Oriented Analysis (173477) FLD6862893<br/><font size="5">Wednesday evening, 7:00 PM-8:30 PM</font>','08/17/2026','10/24/2026'),
 ('Object-Oriented Programming (ADS17) FLD6862894<br/><font size="5">Wednesday evening, 7:00 PM-8:30 PM</font>','09/14/2026','11/21/2026'),
 ('Citizenship and Social Leadership (159976) FLD6893602<br/><font size="5">Wednesday evening, 7:00 PM-8:30 PM</font>','07/15/2026','09/26/2026'),
 ('Distributed Systems and Applications (GTI04) FLD7444606<br/><font size="5">Monday evening, 8:30 PM-10:00 PM</font>','10/12/2026','12/12/2026')]
decl_table = [[Paragraph('COURSE',CELL_B),Paragraph('START',CELL_B),Paragraph('END',CELL_B)]] + [[Paragraph(a,CELL),Paragraph(b,CELL),Paragraph(c,CELL)] for a,b,c in courses]
decl_story = [
 Paragraph('ENROLLMENT CERTIFICATE',TITLE),
 Paragraph('We hereby declare, for all due purposes, that <b>Marcel Aparecido de Andrade</b>, identity document (RG) No. /, CPF No. 363.915.538-66, and student registration No. 37730449, is regularly enrolled in the 3rd semester/module of the <b>Higher Technology Degree in Systems Analysis and Development</b> in the 2026/2 academic term, from June 30, 2026 through December 31, 2026, under a semester-based system, in the Distance Education / Flexible Hybrid format. The on-site support center is located in PRAIA GRANDE/SP.',BODY),
 Paragraph('The evaluation criteria include academic activities, scheduled study activities, assessments, and complementary activities. Academic performance is evaluated by course and is based on attendance, which must be at least 75%, and an achievement grade equal to or greater than 7.0 (seven).',BODY),
 Paragraph('We further declare that meetings take place according to the schedule of the courses listed below.',BODY),
 Table(decl_table,colWidths=[123*mm,22*mm,22*mm],repeatRows=1,style=[('BACKGROUND',(0,0),(-1,0),colors.HexColor('#c9c9c9')),('GRID',(0,0),(-1,-1),0.35,colors.black),('VALIGN',(0,0),(-1,-1),'MIDDLE'),('ALIGN',(1,1),(-1,-1),'CENTER'),('LEFTPADDING',(0,0),(-1,-1),3),('RIGHTPADDING',(0,0),(-1,-1),3),('TOPPADDING',(0,0),(-1,-1),3),('BOTTOMPADDING',(0,0),(-1,-1),3)]),
 Spacer(1,4*mm), Paragraph('The program has a total workload of 2,067 hours, lasts 5 semesters, and is recognized under Ministry of Education Ordinance No. 155 of June 21, 2023, published in Federal Official Gazette No. 117, Section 1, page 241, on June 22, 2023.',BODY),
 Spacer(1,3*mm),Paragraph('Indaial/SC, July 27, 2026.',ParagraphStyle('date2',parent=BODY,alignment=TA_RIGHT)),Spacer(1,3*mm),footer_signature()
]
make_doc(OUT/'Enrollment_Certificate_Third_Semester_EN.pdf','July 27, 2026 - 05:40 AM','2026072700137730449000000000000397839246',decl_story)

records = [
('1','---','Scientific Knowledge Production and Emerging Technologies (159972)<br/>Rodrigo de Paula e Silva Ribeiro -','80','---','---','To be taken'),
('','---','Software Engineering and Design (ADS19)<br/>Rodrigo de Paula e Silva Ribeiro -','80','---','---','To be taken'),
('','---','Fundamentals of Computer Networks (ADS25)<br/>Rodrigo de Paula e Silva Ribeiro -','80','---','---','To be taken'),
('','---','Introduction to Web Systems Development (ADS07)<br/>Rodrigo de Paula e Silva Ribeiro -','80','---','---','To be taken'),
('','2025/2','Professional Immersion: Contemporary Challenges (164016)<br/>Rayane Louise Candida Diniz - Master’s Degree','40','S/A','10.00','Passed'),
('2','2026/1','Professional Perspectives (198471)<br/>Cristian Giacomoni - Doctorate','80','S/A','8.40','Passed'),
('','2026/1','Computer Architecture (INF14)<br/>Caio Steglich Borges - Master’s Degree','80','S/A','8.80','Passed'),
('','2026/1','Programming Logic and Techniques (ADS05)<br/>João Victor Rocha Araújo - Master’s Degree','80','S/A','9.35','Passed'),
('','2026/1','Information Technology Security (GTI08)<br/>Caio Steglich Borges - Master’s Degree','80','S/A','9.50','Passed'),
('','2026/1','Professional Immersion: Career and Success (164019)<br/>Marcelo Borghezan - Doctorate','40','S/A','9.70','Passed'),
('3','2026/2','Citizenship and Social Leadership (159976)<br/>Rodrigo de Paula e Silva Ribeiro -','80','***','***','In progress'),
('','2026/2','Object-Oriented Analysis (173477)<br/>Rodrigo de Paula e Silva Ribeiro -','80','***','***','In progress'),
('','2026/2','Object-Oriented Programming (ADS17)<br/>Rodrigo de Paula e Silva Ribeiro -','80','***','***','In progress'),
('','2026/2','Distributed Systems and Applications (GTI04)<br/>Rodrigo de Paula e Silva Ribeiro -','80','***','***','In progress'),
('','2026/2','Professional Immersion: Artificial Intelligence (173470)<br/>Rodrigo de Paula e Silva Ribeiro -','40','***','***','In progress'),
('4','---','Creative Entrepreneurship (159474)<br/>Rodrigo de Paula e Silva Ribeiro -','80','---','---','To be taken'),
('','---','Databases (172971)<br/>Rodrigo de Paula e Silva Ribeiro -','80','---','---','To be taken'),
('','---','Programming Languages (189476)<br/>Rodrigo de Paula e Silva Ribeiro -','80','---','---','To be taken'),
('','---','Data Structures (189474)<br/>Rodrigo de Paula e Silva Ribeiro -','80','---','---','To be taken'),
('','---','Contemporary and Cross-Curricular Study: Industry, Digital Transformation and Innovation (159479)<br/>Rodrigo de Paula e Silva Ribeiro -','10','---','---','To be taken'),
('','---','Professional Immersion: Database Project (173474)<br/>Rodrigo de Paula e Silva Ribeiro -','40','---','---','To be taken'),
('5','---','Mobile Device Programming (150475)<br/>Rodrigo de Paula e Silva Ribeiro -','80','---','---','To be taken'),
('','---','Web Programming (189475)<br/>Rodrigo de Paula e Silva Ribeiro -','80','---','---','To be taken'),
('','---','Project Management (INF53)<br/>Rodrigo de Paula e Silva Ribeiro -','80','---','---','To be taken'),
('','---','Human-Computer Interaction (ADS02)<br/>Rodrigo de Paula e Silva Ribeiro -','80','---','---','To be taken'),
('','---','Contemporary and Cross-Curricular Study: Intellectual Property, Reading Images, Graphs and Maps (159485)<br/>Rodrigo de Paula e Silva Ribeiro -','10','---','---','To be taken'),
('','---','Professional Immersion: Application Implementation (173478)<br/>Rodrigo de Paula e Silva Ribeiro -','40','---','---','To be taken'),
]

hist = [Paragraph('ACADEMIC TRANSCRIPT',TITLE),Paragraph('Systems Analysis and Development',SUBTITLE),Paragraph('Recognition renewed by Ordinance No. 155 of June 21, 2023, published in the Federal Official Gazette of June 22, 2023, Section 1, pages 237-241.',ParagraphStyle('center',parent=SMALL,alignment=TA_CENTER,spaceAfter=6))]
info = [
 [Paragraph('<b>PERSONAL INFORMATION</b>',LABEL),'',''],
 [Paragraph('<b>Name:</b> Marcel Aparecido de Andrade',SMALL),Paragraph('<b>Sex:</b> Male',SMALL),Paragraph('<b>Date of birth:</b> April 29, 1986',SMALL)],
 [Paragraph('<b>Place of birth:</b> SÃO VICENTE/SP',SMALL),Paragraph('<b>Nationality:</b> Brazilian',SMALL),Paragraph('<b>CPF:</b> 363.915.538-66',SMALL)],
 [Paragraph('<b>DOCUMENTATION / ADMISSION</b>',LABEL),'',''],
 [Paragraph('<b>RG:</b> - | <b>Issuing authority:</b> - | <b>Issue:</b> -',SMALL),Paragraph('<b>Admission method:</b> Entrance examination',SMALL),Paragraph('<b>Notice:</b> 2025/2 | <b>Month/Year:</b> November 2025',SMALL)],
 [Paragraph('<b>HIGHER EDUCATION</b>',LABEL),'',''],
 [Paragraph('<b>Admission year/term:</b> 2025/2',SMALL),Paragraph('<b>Student registration:</b> 37730449',SMALL),Paragraph('<b>Transcript issued:</b> August 16, 2026',SMALL)],
]
hist.append(Table(info,colWidths=[65*mm,52*mm,50*mm],style=[('SPAN',(0,0),(-1,0)),('SPAN',(0,3),(-1,3)),('SPAN',(0,5),(-1,5)),('BACKGROUND',(0,0),(-1,0),colors.HexColor('#e7e7e7')),('BACKGROUND',(0,3),(-1,3),colors.HexColor('#e7e7e7')),('BACKGROUND',(0,5),(-1,5),colors.HexColor('#e7e7e7')),('GRID',(0,0),(-1,-1),0.25,colors.HexColor('#aaaaaa')),('VALIGN',(0,0),(-1,-1),'TOP'),('TOPPADDING',(0,0),(-1,-1),3),('BOTTOMPADDING',(0,0),(-1,-1),3)]))
hist.append(Spacer(1,4*mm))
hdr=[Paragraph('SEM.',CELL_B),Paragraph('TERM',CELL_B),Paragraph('COURSE / INSTRUCTOR',CELL_B),Paragraph('HOURS',CELL_B),Paragraph('ATTEND.',CELL_B),Paragraph('GRADE',CELL_B),Paragraph('STATUS',CELL_B)]
data=[hdr]+[[Paragraph(str(x),CELL) for x in r] for r in records]
hist.append(Table(data,colWidths=[9*mm,16*mm,85*mm,14*mm,15*mm,14*mm,18*mm],repeatRows=1,splitByRow=1,style=[('BACKGROUND',(0,0),(-1,0),colors.HexColor('#c9c9c9')),('GRID',(0,0),(-1,-1),0.25,colors.HexColor('#777777')),('VALIGN',(0,0),(-1,-1),'MIDDLE'),('ALIGN',(0,0),(1,-1),'CENTER'),('ALIGN',(3,1),(-1,-1),'CENTER'),('TOPPADDING',(0,0),(-1,-1),2),('BOTTOMPADDING',(0,0),(-1,-1),2),('LEFTPADDING',(0,0),(-1,-1),2),('RIGHTPADDING',(0,0),(-1,-1),2)]))
summary=[[Paragraph('',CELL),Paragraph('<b>PLANNED HOURS</b>',CELL_B),Paragraph('<b>COMPLETED HOURS</b>',CELL_B)], [Paragraph('<b>SUBTOTAL</b>',CELL_B),'1,820','400'],[Paragraph('COMPLEMENTARY ACTIVITIES¹',CELL_B),'40','0'],[Paragraph('EXTENSION ACTIVITIES²',CELL_B),'207','0'],[Paragraph('TOTAL PROGRAM WORKLOAD',CELL_B),'2,067','400']]
hist += [Spacer(1,4*mm),Table(summary,colWidths=[115*mm,28*mm,28*mm],style=[('GRID',(0,0),(-1,-1),0.3,colors.grey),('BACKGROUND',(0,0),(-1,0),colors.HexColor('#e5e5e5')),('ALIGN',(1,1),(-1,-1),'CENTER'),('TOPPADDING',(0,0),(-1,-1),3),('BOTTOMPADDING',(0,0),(-1,-1),3)]),Spacer(1,2*mm),Paragraph('(SEM.) Program semester<br/>(S/A) Sufficient attendance, i.e., equal to or greater than the institutional requirement.<br/>¹ The student has not completed the required 40 hours of COMPLEMENTARY ACTIVITIES.<br/>² The student has not completed the required 207 hours of EXTENSION ACTIVITIES.',SMALL),Spacer(1,3*mm),footer_signature()]
make_doc(OUT/'Academic_Transcript_Third_Semester_EN.pdf','August 16, 2026 - 06:32 AM','2026081600337730449000000000000402787917',hist)
