import { LightningElement, track } from "lwc";

import stgHealthCheckLoadingIndicator from "@salesforce/label/c.stgHealthCheckLoadingIndicator";

export default class LearnerCourseVisualizer extends LightningElement {
    shouldDisplayCourses = true;
    activeSections = ["000000000000000000"];

    labelReference = {
        spinnerLoadingAltText: stgHealthCheckLoadingIndicator,
    };

    @track learnerCourseViewModel = {
        schemaLabels: {
            assertion: {
                term: "Term",
            },
            achievement: {
                achievementType: "Courses",
            },
        },
        courses: [
            {
                courseConnectionId: "000000000000000000",
                displayGrade: "A",
                status: "Completed",
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
            },

            {
                courseConnectionId: "000000000000000001",
                displayGrade: "A",
                status: "Completed",
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
            },

            {
                courseConnectionId: "000000000000000002",
                displayGrade: "C",
                status: "Completed",
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
            },
        ],
    };

    get shouldDisplayCourses() {
        return !!learnerCourseViewModel;
    }

    get sectionTitle() {
        return "Courses";
    }
}
