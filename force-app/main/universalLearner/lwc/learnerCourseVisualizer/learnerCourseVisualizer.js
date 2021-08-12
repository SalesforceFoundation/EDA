import { LightningElement, track } from "lwc";

import stgHealthCheckLoadingIndicator from "@salesforce/label/c.stgHealthCheckLoadingIndicator";

const MENU_ACTIONS = [{ label: "Show More", value: "showmore" }];
const FIELD_DEFINITIONS = [
    "assertion.achievement.humanCode",
    "custom.status",
    "custom.grade",
    "assertion.creditsEarned",
    "assertion.achievement.creditsAvailable",
    "assertion.achievement.fieldOfStudy",
    "assertion.achievement.level",
    "assertion.term",
    "assertion.activityStartDate",
    "assertion.activityEndDate",
    "custom.verificationStatus",
    "custom.verificationDate",
    "assertion.achievement.issuer.name",
    "assertion.achievement.description",
];

export default class LearnerCourseVisualizer extends LightningElement {
    shouldDisplayCourses = true;
    activeSections = ["000000000000000000"];

    labelReference = {
        spinnerLoadingAltText: stgHealthCheckLoadingIndicator,
        menuAlternativeText: "Show more",
    };

    get menuActions() {
        return MENU_ACTIONS;
    }

    get fieldDefinitions() {
        return FIELD_DEFINITIONS;
    }

    @track learnerCourseViewModel = {
        schemaLabels: {
            assertion: {
                achievement: {
                    achievementType: "Courses",
                    creditsAvailable: "Credits Hours",
                    description: "Extended Description",
                    fieldOfStudy: "Subject",
                    humanCode: "Course Id",
                    issuer: {
                        name: "Issuer",
                    },
                    level: "Academic Level",
                },
                activityEndDate: "End Date",
                activityStartDate: "Start Date",
                creditsEarned: "Credits Earned",
                term: "Term",
            },
            custom: {
                grade: "Grade",
                status: "Status",
                verificationDate: "Verification Date",
                verificationStatus: "Verification Status",
            },
        },
        courses: [
            {
                assertion: {
                    id: "728eb95d-f081-45fa-924c-41e9af805d13",
                    type: "Assertion",
                    achievement: {
                        id: "728eb95d-f081-45fa-924c-41e9af805d12",
                        type: "Achievement",
                        creditsAvailable: 5,
                        description:
                            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas semper risus eu tristique fringilla. Morbi iaculis, elit non fermentum finibus, dolor nunc finibus urna, vitae fermentum metus augue ut arcu. Proin in ante quis velit molestie pharetra. Mauris ligula tellus, sollicitudin et hendrerit non, cursus eget lectus. Ut suscipit felis leo, eget ultricies orci porttitor viverra. Mauris at porta leo. Quisque malesuada erat varius risus sollicitudin consectetur. Sed augue erat, rhoncus vitae nibh non, lobortis dignissim mi. In ullamcorper, metus non rhoncus ornare, diam eros pulvinar ante, sed ornare ligula diam vel ipsum. Vestibulum consectetur magna at urna posuere condimentum.",
                        humanCode: "ECON-101",
                        name: "Intro to Economics",
                        fieldOfStudy: "Economics",
                        issuer: {
                            id: "728eb95d-f081-45fa-924c-41e9af805d11",
                            type: "Profile",
                            email: "registrar@connectedcampus.edu",
                            name: "Connected Campus University",
                        },
                        level: "Undergraduate",
                    },
                    activityEndDate: "2021-02-01",
                    activityStartDate: "2021-01-01",
                    creditsEarned: 5,
                    issuedOn: "2021-03-01",
                    recipient: "100000000000000000",
                    results: "",
                    revoked: "false",
                    role: "Student",
                    source: {
                        id: "728eb95d-f081-45fa-924c-41e9af805d11",
                        type: "Profile",
                        email: "registrar@connectedcampus.edu",
                        name: "Connected Campus University",
                    },
                    term: "Spring 2021",
                },
                custom: {
                    courseConnectionId: "000000000000000000",
                    grade: "A",
                    status: "Completed",
                    verificationDate: "2021-07-01",
                    verificationStatus: "Verified",
                },
            },
            {
                assertion: {
                    id: "728eb95d-f081-45fa-924c-41e9af805d10",
                    type: "Assertion",
                    achievement: {
                        id: "728eb95d-f081-45fa-924c-41e9af805d09",
                        type: "Achievement",
                        creditsAvailable: 3,
                        description:
                            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas semper risus eu tristique fringilla. Morbi iaculis, elit non fermentum finibus, dolor nunc finibus urna, vitae fermentum metus augue ut arcu. Proin in ante quis velit molestie pharetra. Mauris ligula tellus, sollicitudin et hendrerit non, cursus eget lectus. Ut suscipit felis leo, eget ultricies orci porttitor viverra. Mauris at porta leo. Quisque malesuada erat varius risus sollicitudin consectetur. Sed augue erat, rhoncus vitae nibh non, lobortis dignissim mi. In ullamcorper, metus non rhoncus ornare, diam eros pulvinar ante, sed ornare ligula diam vel ipsum. Vestibulum consectetur magna at urna posuere condimentum.",
                        humanCode: "ECON-201",
                        name: "Advanced Economics",
                        fieldOfStudy: "Economics",
                        issuer: {
                            id: "728eb95d-f081-45fa-924c-41e9af805d11",
                            type: "Profile",
                            email: "registrar@connectedcampus.edu",
                            name: "Connected Campus University",
                        },
                        level: "Undergraduate",
                    },
                    activityEndDate: "2021-02-01",
                    activityStartDate: "2021-01-01",
                    creditsEarned: 3,
                    issuedOn: "2021-03-01",
                    recipient: "100000000000000000",
                    results: "",
                    revoked: "false",
                    role: "Student",
                    source: {
                        id: "728eb95d-f081-45fa-924c-41e9af805d11",
                        type: "Profile",
                        email: "registrar@connectedcampus.edu",
                        name: "Connected Campus University",
                    },
                    term: "Spring 2021",
                },
                custom: {
                    courseConnectionId: "000000000000000001",
                    grade: "A",
                    status: "Completed",
                    verificationDate: "2021-07-01",
                    verificationStatus: "Verified",
                },
            },
            {
                assertion: {
                    id: "728eb95d-f081-45fa-924c-41e9af805d08",
                    type: "Assertion",
                    achievement: {
                        id: "728eb95d-f081-45fa-924c-41e9af805d15",
                        type: "Achievement",
                        creditsAvailable: 6,
                        description:
                            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas semper risus eu tristique fringilla. Morbi iaculis, elit non fermentum finibus, dolor nunc finibus urna, vitae fermentum metus augue ut arcu. Proin in ante quis velit molestie pharetra. Mauris ligula tellus, sollicitudin et hendrerit non, cursus eget lectus. Ut suscipit felis leo, eget ultricies orci porttitor viverra. Mauris at porta leo. Quisque malesuada erat varius risus sollicitudin consectetur. Sed augue erat, rhoncus vitae nibh non, lobortis dignissim mi. In ullamcorper, metus non rhoncus ornare, diam eros pulvinar ante, sed ornare ligula diam vel ipsum. Vestibulum consectetur magna at urna posuere condimentum.",
                        humanCode: "PHIL-200",
                        name: "Investigations into Philosophy",
                        fieldOfStudy: "Philosophy",
                        issuer: {
                            id: "728eb95d-f081-45fa-924c-41e9af805d11",
                            type: "Profile",
                            email: "registrar@connectedcampus.edu",
                            name: "Connected Campus University",
                        },
                        level: "Undergraduate",
                    },
                    activityEndDate: "2021-02-01",
                    activityStartDate: "2021-01-01",
                    creditsEarned: 0,
                    issuedOn: "2021-03-01",
                    recipient: "100000000000000000",
                    results: "",
                    revoked: "false",
                    role: "Student",
                    source: {
                        id: "728eb95d-f081-45fa-924c-41e9af805d11",
                        type: "Profile",
                        email: "registrar@connectedcampus.edu",
                        name: "Connected Campus University",
                    },
                    term: "Spring 2021",
                },
                custom: {
                    courseConnectionId: "000000000000000002",
                    grade: "C",
                    status: "Completed",
                    verificationDate: "2021-07-01",
                    verificationStatus: "Verified",
                },
            },
        ],
    };

    get shouldDisplayCourses() {
        return !!learnerCourseViewModel;
    }

    get sectionTitle() {
        return "Courses";
    }

    handleMenuSelect(event) {
        const selectedAction = event.detail.value;
        const assertionViewModel = this.getAssertionViewModelFromAccordionSection(event.target);
        const assertionCourseConnectionId = assertionViewModel.custom.courseConnectionId;
        //This is a stub for lightning navigation in future work
    }

    getAssertionViewModelFromAccordionSection(accordionSection) {
        const assertionElement = accordionSection.querySelector("c-learner-assertion-visualization");
        return assertionElement.learnerAssertionViewModel;
    }
}
